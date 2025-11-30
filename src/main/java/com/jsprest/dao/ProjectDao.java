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
            "SELECT p FROM Project p", Project.class);
        return query.getResultList();
    }

    public void delete(Project project) {
        entityManager.remove(entityManager.contains(project) ? project : entityManager.merge(project));
    }

    public Project findByIdWithTeamMembers(Long id) {
        Project project = entityManager.find(Project.class, id);
        if (project != null) {
            project.getTeamMembers().size();
        }
        return project;
    }
}

