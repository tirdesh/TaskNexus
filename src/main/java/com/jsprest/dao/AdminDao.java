package com.jsprest.dao;

import com.jsprest.entity.Admin;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@Transactional
public class AdminDao {

    @PersistenceContext
    private EntityManager entityManager;

    public Admin findByEmail(String email) {
        TypedQuery<Admin> query = entityManager.createQuery(
            "SELECT a FROM Admin a WHERE a.email = :email", Admin.class);
        query.setParameter("email", email);
        List<Admin> results = query.getResultList();
        return results.isEmpty() ? null : results.get(0);
    }

    public Admin findByUsername(String username) {
        TypedQuery<Admin> query = entityManager.createQuery(
            "SELECT a FROM Admin a WHERE a.username = :username", Admin.class);
        query.setParameter("username", username);
        List<Admin> results = query.getResultList();
        return results.isEmpty() ? null : results.get(0);
    }

    public Admin findById(Long id) {
        return entityManager.find(Admin.class, id);
    }

    public void save(Admin admin) {
        if (admin.getId() == null) {
            entityManager.persist(admin);
        } else {
            entityManager.merge(admin);
        }
    }

    public List<Admin> findAll() {
        TypedQuery<Admin> query = entityManager.createQuery(
            "SELECT a FROM Admin a", Admin.class);
        return query.getResultList();
    }

    public void delete(Admin admin) {
        entityManager.remove(entityManager.contains(admin) ? admin : entityManager.merge(admin));
    }
}

