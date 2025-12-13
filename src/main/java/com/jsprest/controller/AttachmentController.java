package com.jsprest.controller;

import com.jsprest.entity.Attachment;
import com.jsprest.entity.Task;
import com.jsprest.entity.Users;
import com.jsprest.dao.AttachmentDao;
import com.jsprest.dao.TaskDao;
import com.jsprest.dao.UserDao;
import com.jsprest.factory.EntityFactory;
import com.jsprest.factory.MapFactory;
import com.jsprest.service.AuthzService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.HashSet;
import java.util.UUID;

@Controller
public class AttachmentController {

    @Autowired
    private AttachmentDao attachmentDao;

    @Autowired
    private TaskDao taskDao;

    @Autowired
    private UserDao userDao;

    @Autowired
    private EntityFactory entityFactory;

    @Autowired
    private MapFactory mapFactory;

    @Autowired
    private ResourceLoader resourceLoader;

    @Autowired
    private AuthzService authzService;

    @Value("${file.upload.directory:./uploads}")
    private String uploadDirectory;

    private static final Set<String> ALLOWED_CONTENT_TYPES = Set.of(
        "image/jpeg", "image/jpg", "image/png", "image/gif",
        "application/pdf", "application/msword",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document", // .docx
        "application/vnd.ms-excel", // .xls
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", // .xlsx
        "text/plain", "text/csv"
    );

    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024;

    @RequestMapping(value = "/tasks/{taskId}/attachments", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> uploadAttachment(@PathVariable Long taskId, @RequestParam("file") MultipartFile file) {
        Map<String, Object> map = mapFactory.createResponseMap();

        boolean canCommentOrUpload = authzService.canCommentOrUpload(taskId);
        Users currentUser = authzService.getCurrentUser();
        String userInfo = currentUser != null ? currentUser.getUser_name() + " (ID: " + currentUser.getUser_id() + ")" : "Unknown";
        
        if (!canCommentOrUpload) {
            map.put("status", "403");
            map.put("message", "Not authorized to upload attachments to this task. You must be an Admin, Project Manager, Task Assignee, or Team Member of the project.");
            map.put("debug", "User: " + userInfo + ", Task ID: " + taskId + ", canCommentOrUpload: " + canCommentOrUpload);
            return map;
        }

        Task task = taskDao.findById(taskId);
        if (task == null) {
            map.put("status", "404");
            map.put("message", "Task not found");
            return map;
        }

        if (file.isEmpty()) {
            map.put("status", "400");
            map.put("message", "File is empty");
            return map;
        }

        if (file.getSize() > MAX_FILE_SIZE) {
            map.put("status", "400");
            map.put("message", "File size exceeds maximum allowed size of 10MB");
            return map;
        }

        String contentType = file.getContentType();
        if (contentType == null || !ALLOWED_CONTENT_TYPES.contains(contentType)) {
            map.put("status", "400");
            map.put("message", "File type not allowed. Allowed types: images, PDF, Word, Excel, text files");
            return map;
        }

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            map.put("status", "401");
            map.put("message", "User not authenticated");
            return map;
        }
        String email = auth.getName();
        Users user = userDao.findByEmail(email);
        if (user == null) {
            map.put("status", "404");
            map.put("message", "User not found");
            return map;
        }

        try {
            Path uploadPath = Paths.get(uploadDirectory).toAbsolutePath().normalize();
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            String originalFilename = file.getOriginalFilename();
            if (originalFilename == null || originalFilename.isEmpty()) {
                map.put("status", "400");
                map.put("message", "Invalid filename");
                return map;
            }

            String sanitizedFilename = originalFilename
                .replaceAll("[^a-zA-Z0-9._-]", "_");
            
            // Ensure sanitized filename is not empty and limit length
            if (sanitizedFilename.isEmpty()) {
                sanitizedFilename = "file_" + System.currentTimeMillis();
            }
            sanitizedFilename = sanitizedFilename.substring(0, Math.min(255, sanitizedFilename.length()));
            
            String fileName = UUID.randomUUID().toString() + "_" + sanitizedFilename;
            Path filePath = uploadPath.resolve(fileName).normalize();

            if (!filePath.startsWith(uploadPath)) {
                map.put("status", "400");
                map.put("message", "Invalid file path");
                return map;
            }

            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

            Attachment attachment = entityFactory.createAttachment();
            attachment.setFileName(sanitizedFilename);
            attachment.setFilePath(filePath.toString());
            attachment.setFileSize(file.getSize());
            attachment.setTask(task);
            attachment.setUploadedBy(user);

            attachmentDao.save(attachment);
            map.put("status", "200");
            map.put("message", "Attachment has been uploaded successfully");
            map.put("data", attachment);

        } catch (IOException e) {
            map.put("status", "500");
            map.put("message", "Failed to upload file: " + e.getMessage());
        } catch (SecurityException e) {
            map.put("status", "400");
            map.put("message", "Security violation: " + e.getMessage());
        }

        return map;
    }

    @RequestMapping(value = "/tasks/{taskId}/attachments", method = RequestMethod.GET)
    public @ResponseBody
    Map<String, Object> getAttachments(@PathVariable Long taskId) {
        Map<String, Object> map = mapFactory.createResponseMap();

        if (!authzService.canViewTask(taskId)) {
            map.put("status", "403");
            map.put("message", "Not authorized to view this task");
            return map;
        }

        Task task = taskDao.findById(taskId);
        if (task == null) {
            map.put("status", "404");
            map.put("message", "Task not found");
            return map;
        }

        List<Attachment> attachments = attachmentDao.findByTaskId(taskId);
        // Add permission flags for frontend
        map.put("canEdit", authzService.canEditTask(taskId));
        map.put("canCommentOrUpload", authzService.canCommentOrUpload(taskId));
        map.put("status", "200");
        map.put("message", "Data found");
        map.put("data", attachments);

        return map;
    }

    @RequestMapping(value = "/attachments/{id}/download", method = RequestMethod.GET)
    public ResponseEntity<Resource> downloadAttachment(@PathVariable Long id) {
        Attachment attachment = attachmentDao.findById(id);
        if (attachment == null) {
            return ResponseEntity.notFound().build();
        }

        // Check authorization - user must be able to view the task
        if (attachment.getTask() == null || attachment.getTask().getTaskId() == null) {
            return ResponseEntity.badRequest().build();
        }
        
        if (!authzService.canViewTask(attachment.getTask().getTaskId())) {
            return ResponseEntity.status(403).build();
        }

        try {
            Path filePath = Paths.get(attachment.getFilePath());
            Resource resource = resourceLoader.getResource("file:" + filePath.toString());

            if (resource.exists() && resource.isReadable()) {
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_OCTET_STREAM)
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + attachment.getFileName() + "\"")
                    .body(resource);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @RequestMapping(value = "/attachments/{id}", method = RequestMethod.DELETE)
    public @ResponseBody
    Map<String, Object> deleteAttachment(@PathVariable Long id) {
        Map<String, Object> map = mapFactory.createResponseMap();

        Attachment attachment = attachmentDao.findById(id);
        if (attachment == null) {
            map.put("status", "404");
            map.put("message", "Attachment not found");
            return map;
        }

        if (attachment.getTask() == null || attachment.getTask().getTaskId() == null) {
            map.put("status", "400");
            map.put("message", "Attachment is not linked to a task");
            return map;
        }

        // Check if user can edit task (Admin or PM) OR if user is the uploader
        Users currentUser = authzService.getCurrentUser();
        boolean canEditTask = authzService.canEditTask(attachment.getTask().getTaskId());
        boolean isUploader = attachment.getUploadedBy() != null && 
                           currentUser != null &&
                           attachment.getUploadedBy().getUser_id().equals(currentUser.getUser_id());
        
        if (!canEditTask && !isUploader) {
            map.put("status", "403");
            map.put("message", "Not authorized to delete this attachment");
            return map;
        }

        try {
            Path filePath = Paths.get(attachment.getFilePath());
            Files.deleteIfExists(filePath);
            attachmentDao.delete(attachment);
            map.put("status", "200");
            map.put("message", "Attachment has been deleted successfully");
        } catch (IOException e) {
            map.put("status", "500");
            map.put("message", "Failed to delete file: " + e.getMessage());
        }

        return map;
    }
}

