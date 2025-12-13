package com.jsprest.dao;

import com.jsprest.entity.Project;
import com.jsprest.entity.Users;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Repository;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Repository
@Transactional
public class UserDao {

    @PersistenceContext
    private EntityManager entityManager;

    public Users save(Users user) {
        if (user.getUser_id() == null) {
            entityManager.persist(user);
            entityManager.flush();
            return user;
        } else {
            Users mergedUser = entityManager.merge(user);
            entityManager.flush();
            return mergedUser;
        }
    }
    
    public Users findByEmailWithPassword(String email) {
        TypedQuery<Users> query = entityManager.createQuery(
            "SELECT u FROM Users u LEFT JOIN FETCH u.role WHERE u.email = :email", Users.class);
        query.setParameter("email", email);
        List<Users> results = query.getResultList();
        return results.isEmpty() ? null : results.get(0);
    }

    public Users findByIdWithRoles(Integer id) {
        TypedQuery<Users> query = entityManager.createQuery(
            "SELECT u FROM Users u LEFT JOIN FETCH u.role WHERE u.user_id = :id", Users.class);
        query.setParameter("id", id);
        List<Users> results = query.getResultList();
        return results.isEmpty() ? null : results.get(0);
    }

    public Users findById(Integer id) {
        return entityManager.find(Users.class, id);
    }

    public Users findByEmail(String email) {
        TypedQuery<Users> query = entityManager.createQuery(
            "SELECT u FROM Users u LEFT JOIN FETCH u.role WHERE u.email = :email", Users.class);
        query.setParameter("email", email);
        List<Users> results = query.getResultList();
        return results.isEmpty() ? null : results.get(0);
    }

    public List<Users> findAll() {
        TypedQuery<Users> query = entityManager.createQuery(
            "SELECT DISTINCT u FROM Users u LEFT JOIN FETCH u.role", Users.class);
        return query.getResultList();
    }

    public List<Users> findAllNonAdmin() {
        TypedQuery<Users> query = entityManager.createQuery(
            "SELECT DISTINCT u FROM Users u LEFT JOIN FETCH u.role", Users.class);
        List<Users> allUsers = query.getResultList();
        
        return allUsers.stream()
            .filter(user -> {
                if (user.getRole() == null || user.getRole().isEmpty()) {
                    return true;
                }
                return user.getRole().stream()
                    .noneMatch(role -> role != null && "ROLE_ADMIN".equals(role.getName()));
            })
            .toList();
    }

    public void delete(Users user) {
        entityManager.remove(entityManager.contains(user) ? user : entityManager.merge(user));
    }

    public List<Users> findAllPaginated(int pageNumber, int pageSize) {
        TypedQuery<Users> query = entityManager.createQuery(
            "SELECT DISTINCT u FROM Users u LEFT JOIN FETCH u.role ORDER BY u.user_id", Users.class);
        query.setFirstResult((pageNumber - 1) * pageSize);
        query.setMaxResults(pageSize);
        return query.getResultList();
    }

    public Long countAll() {
        TypedQuery<Long> query = entityManager.createQuery("SELECT count(u) FROM Users u", Long.class);
        return query.getSingleResult();
    }

    public List<Users> findUsersInRelatedProjects(Integer userId) {
        // First, find all projects the user is associated with (as manager or team member)
        TypedQuery<Project> projectQuery = entityManager.createQuery(
            "SELECT DISTINCT p FROM Project p LEFT JOIN p.teamMembers tm " +
            "WHERE p.projectManager.user_id = :userId OR tm.user_id = :userId", Project.class);
        projectQuery.setParameter("userId", userId);
        List<Project> relatedProjects = projectQuery.getResultList();

        if (relatedProjects.isEmpty()) {
            return List.of();
        }

        Set<Long> projectIds = relatedProjects.stream().map(Project::getProjectId).collect(Collectors.toSet());

        // Now, find all unique users (managers and team members) from those projects
        TypedQuery<Users> userQuery = entityManager.createQuery(
            "SELECT DISTINCT u FROM Project p " +
            "JOIN p.teamMembers u " +
            "WHERE p.projectId IN :projectIds", Users.class);
        userQuery.setParameter("projectIds", projectIds);
        Set<Users> users = new HashSet<>(userQuery.getResultList());

        TypedQuery<Users> managerQuery = entityManager.createQuery(
            "SELECT DISTINCT p.projectManager FROM Project p WHERE p.projectId IN :projectIds", Users.class);
        managerQuery.setParameter("projectIds", projectIds);
        users.addAll(managerQuery.getResultList());

        return users.stream().collect(Collectors.toList());
    }
}
