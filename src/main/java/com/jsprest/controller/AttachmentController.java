package com.jsprest.controller;

import com.jsprest.entity.Attachment;
import com.jsprest.entity.Task;
import com.jsprest.entity.Users;
import com.jsprest.dao.AttachmentDao;
import com.jsprest.dao.TaskDao;
import com.jsprest.dao.UserDao;
import com.jsprest.factory.EntityFactory;
import com.jsprest.factory.MapFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
// TODO: Re-enable security imports later
// import org.springframework.security.core.Authentication;
// import org.springframework.security.core.context.SecurityContextHolder;
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

    @Value("${file.upload.directory:./uploads}")
    private String uploadDirectory;

    @RequestMapping(value = "/tasks/{taskId}/attachments", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> uploadAttachment(@PathVariable Long taskId, @RequestParam("file") MultipartFile file) {
        Map<String, Object> map = mapFactory.createResponseMap();

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

        // TODO: Re-enable authentication later
        // Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        // if (auth == null) {
        //     map.put("status", "401");
        //     map.put("message", "User not authenticated");
        //     return map;
        // }
        // String email = auth.getName();
        // Temporary: Use first user for now
        Users user = userDao.findAll().isEmpty() ? null : userDao.findAll().get(0);
        if (user == null) {
            map.put("status", "404");
            map.put("message", "User not found");
            return map;
        }

        try {
            Path uploadPath = Paths.get(uploadDirectory);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            String fileName = UUID.randomUUID().toString() + "_" + file.getOriginalFilename();
            Path filePath = uploadPath.resolve(fileName);
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

            Attachment attachment = entityFactory.createAttachment();
            attachment.setFileName(file.getOriginalFilename());
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
        }

        return map;
    }

    @RequestMapping(value = "/tasks/{taskId}/attachments", method = RequestMethod.GET)
    public @ResponseBody
    Map<String, Object> getAttachments(@PathVariable Long taskId) {
        Map<String, Object> map = mapFactory.createResponseMap();

        Task task = taskDao.findById(taskId);
        if (task == null) {
            map.put("status", "404");
            map.put("message", "Task not found");
            return map;
        }

        List<Attachment> attachments = attachmentDao.findByTaskId(taskId);
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

