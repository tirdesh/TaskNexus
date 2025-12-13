package com.jsprest.dao;

import com.jsprest.entity.Project;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@Transactional
public class ProjectDao {

    @PersistenceContext
    private EntityManager entityManager;

    public void save(Project project) {
        if (project.getProjectId() == null) {
            entityManager.persist(project);
        } else {
            entityManager.merge(project);
        }
    }

    public Project findById(Long id) {
        return entityManager.find(Project.class, id);
    }

    public List<Project> findAll() {
        TypedQuery<Project> query = entityManager.createQuery(
            "SELECT DISTINCT p FROM Project p LEFT JOIN FETCH p.projectManager", Project.class);
        return query.getResultList();
    }

    public void delete(Project project) {
        entityManager.remove(entityManager.contains(project) ? project : entityManager.merge(project));
    }

    public Project findByIdWithTeamMembers(Long id) {
        TypedQuery<Project> query = entityManager.createQuery(
            "SELECT DISTINCT p FROM Project p LEFT JOIN FETCH p.teamMembers LEFT JOIN FETCH p.projectManager WHERE p.projectId = :id", Project.class);
        query.setParameter("id", id);
        List<Project> results = query.getResultList();
        return results.isEmpty() ? null : results.get(0);
    }
    
    public List<Project> findAllPaginated(int pageNumber, int pageSize) {
        TypedQuery<Project> query = entityManager.createQuery(
            "SELECT DISTINCT p FROM Project p LEFT JOIN FETCH p.projectManager ORDER BY p.projectId", Project.class);
        query.setFirstResult((pageNumber - 1) * pageSize);
        query.setMaxResults(pageSize);
        return query.getResultList();
    }

    public List<Project> searchProjects(String searchTerm) {
        if (searchTerm == null || searchTerm.trim().isEmpty()) {
            return findAll();
        }
        
        // Fetch all projects and filter in Java to avoid Hibernate type issues with LOB fields
        // This approach works with all field types including @Lob
        List<Project> allProjects = findAll();
        String lowerSearchTerm = searchTerm.trim().toLowerCase();
        
        return allProjects.stream()
            .filter(p -> {
                if (p == null) return false;
                String name = p.getName() != null ? p.getName().toLowerCase() : "";
                String description = p.getDescription() != null ? p.getDescription().toLowerCase() : "";
                return name.contains(lowerSearchTerm) || description.contains(lowerSearchTerm);
            })
            .toList();
    }

    public Long countAll() {
        TypedQuery<Long> query = entityManager.createQuery("SELECT count(p) FROM Project p", Long.class);
        return query.getSingleResult();
    }

    public Long countProjectsForUser(Integer userId) {
        TypedQuery<Long> query = entityManager.createQuery(
            "SELECT count(DISTINCT p) FROM Project p LEFT JOIN p.teamMembers tm WHERE p.projectManager.user_id = :userId OR tm.user_id = :userId", Long.class);
        query.setParameter("userId", userId);
        return query.getSingleResult();
    }
}
