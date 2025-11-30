package com.jsprest.dao;

import com.jsprest.entity.Task;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@Transactional
public class TaskDao {

    @PersistenceContext
    private EntityManager entityManager;

    public void save(Task task) {
        if (task.getTaskId() == null) {
            entityManager.persist(task);
        } else {
            entityManager.merge(task);
        }
    }

    public Task findById(Long id) {
        return entityManager.find(Task.class, id);
    }

    public List<Task> findAll() {
        TypedQuery<Task> query = entityManager.createQuery(
            "SELECT t FROM Task t", Task.class);
        return query.getResultList();
    }

    public void delete(Task task) {
        entityManager.remove(entityManager.contains(task) ? task : entityManager.merge(task));
    }

    public List<Task> findByProjectId(Long projectId) {
        TypedQuery<Task> query = entityManager.createQuery(
            "SELECT t FROM Task t WHERE t.project.projectId = :projectId", Task.class);
        query.setParameter("projectId", projectId);
        return query.getResultList();
    }

    public List<Task> findByAssignedUserId(Integer userId) {
        TypedQuery<Task> query = entityManager.createQuery(
            "SELECT t FROM Task t WHERE t.assignedTo.user_id = :userId", Task.class);
        query.setParameter("userId", userId);
        return query.getResultList();
    }

    public void updateStatus(Long taskId, com.jsprest.entity.enums.TaskStatus status) {
        Task task = findById(taskId);
        if (task != null) {
            task.setTaskStatus(status);
            entityManager.merge(task);
        }
    }
}

