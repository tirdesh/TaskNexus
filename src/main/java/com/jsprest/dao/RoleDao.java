package com.jsprest.dao;

import com.jsprest.entity.Role;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@Transactional
public class RoleDao {

    @PersistenceContext
    private EntityManager entityManager;

    public Role findById(Long id) {
        return entityManager.find(Role.class, id);
    }

    public Role findByName(String name) {
        TypedQuery<Role> query = entityManager.createQuery(
            "SELECT r FROM Role r WHERE r.name = :name", Role.class);
        query.setParameter("name", name);
        List<Role> results = query.getResultList();
        return results.isEmpty() ? null : results.get(0);
    }

    public List<Role> findAll() {
        TypedQuery<Role> query = entityManager.createQuery(
            "SELECT r FROM Role r", Role.class);
        return query.getResultList();
    }

    public void save(Role role) {
        if (role.getRoleId() == null) {
            entityManager.persist(role);
        } else {
            entityManager.merge(role);
        }
    }
}

