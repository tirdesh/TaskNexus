package com.jsprest.dao;

import com.jsprest.entity.Comment;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@Transactional
public class CommentDao {

    @PersistenceContext
    private EntityManager entityManager;

    public void save(Comment comment) {
        if (comment.getCommentId() == null) {
            entityManager.persist(comment);
        } else {
            entityManager.merge(comment);
        }
    }

    public Comment findById(Long id) {
        return entityManager.find(Comment.class, id);
    }

    public List<Comment> findByTaskId(Long taskId) {
        TypedQuery<Comment> query = entityManager.createQuery(
            "SELECT DISTINCT c FROM Comment c LEFT JOIN FETCH c.createdBy WHERE c.task.taskId = :taskId ORDER BY c.createdAt DESC", Comment.class);
        query.setParameter("taskId", taskId);
        return query.getResultList();
    }

    public void delete(Comment comment) {
        entityManager.remove(entityManager.contains(comment) ? comment : entityManager.merge(comment));
    }
}

