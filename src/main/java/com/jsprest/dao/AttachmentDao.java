package com.jsprest.dao;

import com.jsprest.entity.Attachment;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@Transactional
public class AttachmentDao {

    @PersistenceContext
    private EntityManager entityManager;

    public void save(Attachment attachment) {
        if (attachment.getAttachmentId() == null) {
            entityManager.persist(attachment);
        } else {
            entityManager.merge(attachment);
        }
    }

    public Attachment findById(Long id) {
        return entityManager.find(Attachment.class, id);
    }

    public List<Attachment> findByTaskId(Long taskId) {
        TypedQuery<Attachment> query = entityManager.createQuery(
            "SELECT DISTINCT a FROM Attachment a LEFT JOIN FETCH a.uploadedBy WHERE a.task.taskId = :taskId ORDER BY a.uploadedAt DESC", Attachment.class);
        query.setParameter("taskId", taskId);
        return query.getResultList();
    }

    public void delete(Attachment attachment) {
        entityManager.remove(entityManager.contains(attachment) ? attachment : entityManager.merge(attachment));
    }
}

