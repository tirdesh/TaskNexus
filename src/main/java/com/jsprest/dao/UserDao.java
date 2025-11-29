package com.jsprest.dao;

import com.jsprest.entity.Users;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@Transactional
public class UserDao {

    @PersistenceContext
    private EntityManager entityManager;

    public Users save(Users user) {
        if (user.getUser_id() == null) {
            entityManager.persist(user);
            entityManager.flush(); // Ensure user_id is generated
            return user;
        } else {
            // For updates, merge the user and ensure roles are properly managed
            Users mergedUser = entityManager.merge(user);
            entityManager.flush();
            return mergedUser;
        }
    }
    
    public Users findByEmailWithPassword(String email) {
        TypedQuery<Users> query = entityManager.createQuery(
            "SELECT u FROM Users u WHERE u.email = :email", Users.class);
        query.setParameter("email", email);
        List<Users> results = query.getResultList();
        return results.isEmpty() ? null : results.get(0);
    }

    public Users findByIdWithRoles(Integer id) {
        Users user = entityManager.find(Users.class, id);
        if (user != null) {
            // Force loading of roles
            user.getRole().size();
        }
        return user;
    }

    public Users findById(Integer id) {
        return entityManager.find(Users.class, id);
    }

    public Users findByEmail(String email) {
        TypedQuery<Users> query = entityManager.createQuery(
            "SELECT u FROM Users u WHERE u.email = :email", Users.class);
        query.setParameter("email", email);
        List<Users> results = query.getResultList();
        return results.isEmpty() ? null : results.get(0);
    }

    public List<Users> findAll() {
        TypedQuery<Users> query = entityManager.createQuery(
            "SELECT DISTINCT u FROM Users u LEFT JOIN FETCH u.role", Users.class);
        return query.getResultList();
    }

    public void delete(Users user) {
        entityManager.remove(entityManager.contains(user) ? user : entityManager.merge(user));
    }
}

