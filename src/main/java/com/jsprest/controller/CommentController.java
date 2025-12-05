package com.jsprest.controller;

import com.jsprest.entity.Comment;
import com.jsprest.entity.Task;
import com.jsprest.entity.Users;
import com.jsprest.dao.CommentDao;
import com.jsprest.dao.TaskDao;
import com.jsprest.dao.UserDao;
import com.jsprest.factory.EntityFactory;
import com.jsprest.factory.MapFactory;
import org.springframework.beans.factory.annotation.Autowired;
// TODO: Re-enable security imports later
// import org.springframework.security.core.Authentication;
// import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;
import java.util.Map;

@Controller
public class CommentController {

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

    @RequestMapping(value = "/tasks/{taskId}/comments", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> addComment(@PathVariable Long taskId, @RequestParam String content) {
        Map<String, Object> map = mapFactory.createResponseMap();

        Task task = taskDao.findById(taskId);
        if (task == null) {
            map.put("status", "404");
            map.put("message", "Task not found");
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

        Comment comment = entityFactory.createComment();
        comment.setContent(content);
        comment.setTask(task);
        comment.setCreatedBy(user);

        commentDao.save(comment);
        map.put("status", "200");
        map.put("message", "Comment has been added successfully");
        map.put("data", comment);

        return map;
    }

    @RequestMapping(value = "/tasks/{taskId}/comments", method = RequestMethod.GET)
    public @ResponseBody
    Map<String, Object> getComments(@PathVariable Long taskId) {
        Map<String, Object> map = mapFactory.createResponseMap();

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

