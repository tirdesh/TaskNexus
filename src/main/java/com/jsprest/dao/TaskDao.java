package com.jsprest.dao;

import com.jsprest.entity.Task;
import com.jsprest.entity.enums.Priority;
import com.jsprest.entity.enums.TaskStatus;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Repository;
import org.springframework.util.StringUtils;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
        // Fetch project and project manager to ensure permission checks work correctly
        TypedQuery<Task> query = entityManager.createQuery(
            "SELECT DISTINCT t FROM Task t LEFT JOIN FETCH t.project p LEFT JOIN FETCH p.projectManager LEFT JOIN FETCH t.assignedTo", Task.class);
        return query.getResultList();
    }

    public void delete(Task task) {
        entityManager.remove(entityManager.contains(task) ? task : entityManager.merge(task));
    }

    public List<Task> findByProjectId(Long projectId) {
        TypedQuery<Task> query = entityManager.createQuery(
            "SELECT DISTINCT t FROM Task t LEFT JOIN FETCH t.project LEFT JOIN FETCH t.assignedTo WHERE t.project.projectId = :projectId", Task.class);
        query.setParameter("projectId", projectId);
        return query.getResultList();
    }

    public List<Task> findByAssignedUserId(Integer userId) {
        // Fetch project and project manager to ensure permission checks work correctly
        TypedQuery<Task> query = entityManager.createQuery(
            "SELECT DISTINCT t FROM Task t LEFT JOIN FETCH t.project p LEFT JOIN FETCH p.projectManager LEFT JOIN FETCH t.assignedTo WHERE t.assignedTo.user_id = :userId", Task.class);
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

    public Task findByIdWithProjectAndAssignedUser(Long id) {
        // Fetch project and project manager to ensure permission checks work correctly
        TypedQuery<Task> query = entityManager.createQuery(
            "SELECT DISTINCT t FROM Task t LEFT JOIN FETCH t.project p LEFT JOIN FETCH p.projectManager LEFT JOIN FETCH t.assignedTo LEFT JOIN FETCH t.createdBy WHERE t.taskId = :id", Task.class);
        query.setParameter("id", id);
        List<Task> results = query.getResultList();
        return results.isEmpty() ? null : results.get(0);
    }

    public List<Task> findFilteredPaginated(int pageNumber, int pageSize, Long projectId, Integer assigneeId, TaskStatus status, Priority priority) {
        return findFilteredPaginated(pageNumber, pageSize, projectId, assigneeId, status, priority, false);
    }

    public List<Task> findFilteredPaginated(int pageNumber, int pageSize, Long projectId, Integer assigneeId, TaskStatus status, Priority priority, boolean activeOnly) {
        // Fetch project and project manager to ensure permission checks work correctly
        StringBuilder qlString = new StringBuilder("SELECT DISTINCT t FROM Task t LEFT JOIN FETCH t.project p LEFT JOIN FETCH p.projectManager LEFT JOIN FETCH t.assignedTo WHERE 1=1");
        Map<String, Object> params = new HashMap<>();

        if (projectId != null) {
            qlString.append(" AND t.project.projectId = :projectId");
            params.put("projectId", projectId);
        }
        if (assigneeId != null) {
            qlString.append(" AND t.assignedTo.user_id = :assigneeId");
            params.put("assigneeId", assigneeId);
        }
        if (status != null) {
            qlString.append(" AND t.taskStatus = :status");
            params.put("status", status);
        }
        if (activeOnly) {
            // Filter for active tasks only (exclude COMPLETED)
            qlString.append(" AND t.taskStatus IN :activeStatus");
            params.put("activeStatus", Arrays.asList(TaskStatus.TODO, TaskStatus.IN_PROGRESS, TaskStatus.BLOCKED));
        }
        if (priority != null) {
            qlString.append(" AND t.priority = :priority");
            params.put("priority", priority);
        }

        qlString.append(" ORDER BY t.taskId");

        TypedQuery<Task> query = entityManager.createQuery(qlString.toString(), Task.class);
        for (Map.Entry<String, Object> entry : params.entrySet()) {
            query.setParameter(entry.getKey(), entry.getValue());
        }

        query.setFirstResult((pageNumber - 1) * pageSize);
        query.setMaxResults(pageSize);
        return query.getResultList();
    }

    public Long countFiltered(Long projectId, Integer assigneeId, TaskStatus status, Priority priority) {
        return countFiltered(projectId, assigneeId, status, priority, false);
    }

    public Long countFiltered(Long projectId, Integer assigneeId, TaskStatus status, Priority priority, boolean activeOnly) {
        StringBuilder qlString = new StringBuilder("SELECT count(DISTINCT t.taskId) FROM Task t WHERE 1=1");
        Map<String, Object> params = new HashMap<>();

        if (projectId != null) {
            qlString.append(" AND t.project.projectId = :projectId");
            params.put("projectId", projectId);
        }
        if (assigneeId != null) {
            qlString.append(" AND t.assignedTo.user_id = :assigneeId");
            params.put("assigneeId", assigneeId);
        }
        if (status != null) {
            qlString.append(" AND t.taskStatus = :status");
            params.put("status", status);
        }
        if (activeOnly) {
            // Filter for active tasks only (exclude COMPLETED)
            qlString.append(" AND t.taskStatus IN :activeStatus");
            params.put("activeStatus", Arrays.asList(TaskStatus.TODO, TaskStatus.IN_PROGRESS, TaskStatus.BLOCKED));
        }
        if (priority != null) {
            qlString.append(" AND t.priority = :priority");
            params.put("priority", priority);
        }

        TypedQuery<Long> query = entityManager.createQuery(qlString.toString(), Long.class);
        for (Map.Entry<String, Object> entry : params.entrySet()) {
            query.setParameter(entry.getKey(), entry.getValue());
        }

        return query.getSingleResult();
    }

    public Long countAll() {
        TypedQuery<Long> query = entityManager.createQuery("SELECT count(t) FROM Task t", Long.class);
        return query.getSingleResult();
    }

    public Long countTasksForUser(Integer userId) {
        TypedQuery<Long> query = entityManager.createQuery(
            "SELECT count(DISTINCT t) FROM Task t JOIN t.project p LEFT JOIN p.teamMembers tm WHERE p.projectManager.user_id = :userId OR tm.user_id = :userId", Long.class);
        query.setParameter("userId", userId);
        return query.getSingleResult();
    }

    public Long countActiveTasksForUser(Integer userId) {
        TypedQuery<Long> query = entityManager.createQuery(
            "SELECT count(DISTINCT t) FROM Task t JOIN t.project p LEFT JOIN p.teamMembers tm WHERE (p.projectManager.user_id = :userId OR tm.user_id = :userId) AND t.taskStatus IN :activeStatus", Long.class);
        query.setParameter("userId", userId);
        query.setParameter("activeStatus", Arrays.asList(TaskStatus.TODO, TaskStatus.IN_PROGRESS, TaskStatus.BLOCKED));
        return query.getSingleResult();
    }

    public Long countTasksByAssignee(Integer userId) {
        TypedQuery<Long> query = entityManager.createQuery(
            "SELECT count(t) FROM Task t WHERE t.assignedTo.user_id = :userId", Long.class);
        query.setParameter("userId", userId);
        return query.getSingleResult();
    }

    public Long countAllActiveTasks() {
        TypedQuery<Long> query = entityManager.createQuery(
            "SELECT count(t) FROM Task t WHERE t.taskStatus IN :activeStatus", Long.class);
        query.setParameter("activeStatus", Arrays.asList(TaskStatus.TODO, TaskStatus.IN_PROGRESS, TaskStatus.BLOCKED));
        return query.getSingleResult();
    }
}
