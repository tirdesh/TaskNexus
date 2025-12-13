package com.jsprest.controller;

import com.jsprest.entity.Comment;
import com.jsprest.entity.Task;
import com.jsprest.entity.Users;
import com.jsprest.dao.CommentDao;
import com.jsprest.dao.TaskDao;
import com.jsprest.dao.UserDao;
import com.jsprest.factory.EntityFactory;
import com.jsprest.factory.MapFactory;
import com.jsprest.service.AuthzService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;
import java.util.Map;

@Controller
public class CommentController {

    private static final Logger logger = LoggerFactory.getLogger(CommentController.class);

    @Autowired
    private CommentDao commentDao;

    @Autowired
    private TaskDao taskDao;

    @Autowired
    private UserDao userDao;

    @Autowired
    private EntityFactory entityFactory;

    @Autowired
    private MapFactory mapFactory;

    @Autowired
    private AuthzService authzService;

    @RequestMapping(value = "/tasks/{taskId}/comments", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> addComment(@PathVariable Long taskId, @RequestParam String content) {
        Map<String, Object> map = mapFactory.createResponseMap();

        boolean canCommentOrUpload = authzService.canCommentOrUpload(taskId);
        Users currentUser = authzService.getCurrentUser();
        String userInfo = currentUser != null ? currentUser.getUser_name() + " (ID: " + currentUser.getUser_id() + ")" : "Unknown";
        
        if (!canCommentOrUpload) {
            map.put("status", "403");
            map.put("message", "Not authorized to add comments to this task. You must be an Admin, Project Manager, Task Assignee, or Team Member of the project.");
            map.put("debug", "User: " + userInfo + ", Task ID: " + taskId + ", canCommentOrUpload: " + canCommentOrUpload);
            return map;
        }

        Task task = taskDao.findById(taskId);
        if (task == null) {
            map.put("status", "404");
            map.put("message", "Task not found");
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

        // Validate comment content
        if (content == null || content.trim().isEmpty()) {
            map.put("status", "400");
            map.put("message", "Comment content is required");
            return map;
        }
        
        String trimmedContent = content.trim();
        if (trimmedContent.length() > 5000) {
            map.put("status", "400");
            map.put("message", "Comment must not exceed 5000 characters");
            return map;
        }

        Comment comment = entityFactory.createComment();
        comment.setContent(trimmedContent);
        comment.setTask(task);
        comment.setCreatedBy(user);

        try {
            commentDao.save(comment);
            map.put("status", "200");
            map.put("message", "Comment has been added successfully");
            map.put("data", comment);
        } catch (jakarta.validation.ConstraintViolationException e) {
            logger.error("Validation error saving comment", e);
            // Extract user-friendly validation messages
            StringBuilder errorMsg = new StringBuilder("Validation failed: ");
            e.getConstraintViolations().forEach(violation -> {
                if (errorMsg.length() > "Validation failed: ".length()) {
                    errorMsg.append(", ");
                }
                errorMsg.append(violation.getMessage());
            });
            map.put("status", "400");
            map.put("message", errorMsg.toString());
        } catch (Exception e) {
            logger.error("Error saving comment", e);
            String errorMessage = e.getMessage();
            if (errorMessage != null && errorMessage.contains("ConstraintViolation")) {
                map.put("status", "400");
                map.put("message", "Validation failed. Please check your input.");
            } else {
                map.put("status", "500");
                map.put("message", "Error saving comment: " + errorMessage);
            }
        }

        return map;
    }

    @RequestMapping(value = "/tasks/{taskId}/comments", method = RequestMethod.GET)
    public @ResponseBody
    Map<String, Object> getComments(@PathVariable Long taskId) {
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

        List<Comment> comments = commentDao.findByTaskId(taskId);
        map.put("status", "200");
        map.put("message", "Data found");
        map.put("data", comments);

        return map;
    }
}

