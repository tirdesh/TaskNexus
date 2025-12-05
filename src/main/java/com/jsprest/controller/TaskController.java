package com.jsprest.controller;

import com.jsprest.entity.Task;
import com.jsprest.entity.Users;
import com.jsprest.entity.Project;
import com.jsprest.entity.enums.TaskStatus;
import com.jsprest.dao.TaskDao;
import com.jsprest.dao.UserDao;
import com.jsprest.dao.ProjectDao;
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
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.ResponseBody;
import jakarta.servlet.http.HttpSession;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import java.util.List;
import java.util.Map;


@Controller
public class TaskController {


    @Autowired
    private TaskDao taskDao;

    @Autowired
    private UserDao userDao;

    @Autowired
    private ProjectDao projectDao;

    @Autowired
    private EntityFactory entityFactory;

    @Autowired
    private MapFactory mapFactory;

    @RequestMapping(value = "/saveTask", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> getSaved(@RequestBody Map<String, Object> taskData) {
        Map<String, Object> map = mapFactory.createResponseMap();

        try {
            Task task = entityFactory.createTask();
            
            if (taskData.containsKey("taskId") && taskData.get("taskId") != null && !taskData.get("taskId").toString().isEmpty()) {
                Long taskId = Long.parseLong(taskData.get("taskId").toString());
                Task existingTask = taskDao.findById(taskId);
                if (existingTask != null) {
                    task = existingTask;
                }
            }
            
            if (taskData.containsKey("name")) {
                task.setName(taskData.get("name").toString());
            }
            
            if (taskData.containsKey("description")) {
                task.setDescription(taskData.get("description").toString());
            }
            
            if (taskData.containsKey("priority") && taskData.get("priority") != null && !taskData.get("priority").toString().isEmpty()) {
                try {
                    com.jsprest.entity.enums.Priority priority = com.jsprest.entity.enums.Priority.valueOf(taskData.get("priority").toString());
                    task.setPriority(priority);
                } catch (IllegalArgumentException e) {
                    // Ignore invalid priority
                }
            }
            
            if (taskData.containsKey("taskStatus") && taskData.get("taskStatus") != null) {
                try {
                    TaskStatus taskStatus = TaskStatus.valueOf(taskData.get("taskStatus").toString());
                    task.setTaskStatus(taskStatus);
                } catch (IllegalArgumentException e) {
                    // Ignore invalid status
                }
            }
            
            if (taskData.containsKey("deadline") && taskData.get("deadline") != null && !taskData.get("deadline").toString().isEmpty()) {
                try {
                    String deadlineStr = taskData.get("deadline").toString();
                    LocalDateTime deadline = LocalDateTime.parse(deadlineStr.replace("T", "T"), DateTimeFormatter.ISO_LOCAL_DATE_TIME);
                    task.setDeadline(deadline);
                } catch (Exception e) {
                    // Ignore invalid date
                }
            }
            
            if (taskData.containsKey("project") && taskData.get("project") != null) {
                @SuppressWarnings("unchecked")
                Map<String, Object> projectMap = (Map<String, Object>) taskData.get("project");
                if (projectMap.containsKey("projectId")) {
                    Long projectId = Long.parseLong(projectMap.get("projectId").toString());
                    Project project = projectDao.findById(projectId);
                    if (project != null) {
                        task.setProject(project);
                    }
                }
            }
            
            if (taskData.containsKey("assignedTo") && taskData.get("assignedTo") != null) {
                @SuppressWarnings("unchecked")
                Map<String, Object> userMap = (Map<String, Object>) taskData.get("assignedTo");
                if (userMap.containsKey("user_id")) {
                    Integer userId = Integer.parseInt(userMap.get("user_id").toString());
                    Users user = userDao.findById(userId);
                    if (user != null) {
                        task.setAssignedTo(user);
                    }
                }
            }

            taskDao.save(task);
            map.put("status", "200");
            map.put("message", "Task has been saved successfully");
        } catch (Exception e) {
            map.put("status", "500");
            map.put("message", "Error saving task: " + e.getMessage());
            e.printStackTrace();
        }

        return map;
    }


    @RequestMapping(value = "/viewTask", method = RequestMethod.GET)
    public String getPage11() {

        return "task/viewTask";
    }


    @RequestMapping(value = "/addTask", method = RequestMethod.GET)
    public String addTask() {

        return "task/addTask";
    }


    @RequestMapping(value = "/allTask", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> getAll(Task task) {
        Map<String, Object> map = mapFactory.createResponseMap();

        List<Task> allTask = taskDao.findAll();

        if (allTask != null) {
            map.put("status", "200");
            map.put("message", "Data found");
            map.put("data", allTask);
        } else {
            map.put("status", "404");
            map.put("message", "Task not found");

        }

        System.out.println(map);
        return map;
    }


    @RequestMapping(value = "/deleteTask", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> delete(Task task) {
        Map<String, Object> map = mapFactory.createResponseMap();

        taskDao.delete(task);
        map.put("status", "200");
        map.put("message", "Your task has been deleted successfully");

        System.out.println(map);
        return map;
    }

    @RequestMapping(value = "/assignTask", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> assignTask(@RequestParam Long taskId, @RequestParam Integer userId) {
        Map<String, Object> map = mapFactory.createResponseMap();

        Task task = taskDao.findById(taskId);
        if (task == null) {
            map.put("status", "404");
            map.put("message", "Task not found");
            return map;
        }

        Users user = userDao.findById(userId);
        if (user == null) {
            map.put("status", "404");
            map.put("message", "User not found");
            return map;
        }

        task.setAssignedTo(user);
        taskDao.save(task);
        map.put("status", "200");
        map.put("message", "Task has been assigned successfully");

        return map;
    }

    @RequestMapping(value = "/myTasks", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> getMyTasks(HttpSession session) {
        Map<String, Object> map = mapFactory.createResponseMap();

        Integer userId = (Integer) session.getAttribute("userId");
        if (userId != null) {
            List<Task> myTasks = taskDao.findByAssignedUserId(userId);
            map.put("status", "200");
            map.put("message", "Data found");
            map.put("data", myTasks);
        } else {
            map.put("status", "401");
            map.put("message", "User not logged in");
        }

        return map;
    }

    @RequestMapping(value = "/updateTaskStatus", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> updateTaskStatus(@RequestParam Long taskId, @RequestParam String status) {
        Map<String, Object> map = mapFactory.createResponseMap();

        Task task = taskDao.findById(taskId);
        if (task == null) {
            map.put("status", "404");
            map.put("message", "Task not found");
            return map;
        }

        try {
            TaskStatus taskStatus = TaskStatus.valueOf(status.toUpperCase());
            taskDao.updateStatus(taskId, taskStatus);
            map.put("status", "200");
            map.put("message", "Task status has been updated successfully");
        } catch (IllegalArgumentException e) {
            map.put("status", "400");
            map.put("message", "Invalid task status: " + status);
        }

        return map;
    }

    @RequestMapping(value = "/task/{taskId}", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> getTaskDetail(@PathVariable Long taskId) {
        Map<String, Object> map = mapFactory.createResponseMap();

        Task task = taskDao.findById(taskId);
        if (task != null) {
            map.put("status", "200");
            map.put("message", "Data found");
            map.put("data", task);
        } else {
            map.put("status", "404");
            map.put("message", "Task not found");
        }

        return map;
    }

    @RequestMapping(value = "/myTasks", method = RequestMethod.GET)
    public String myTasksPage() {
        return "task/myTasks";
    }

    @RequestMapping(value = "/task/{taskId}", method = RequestMethod.GET)
    public String viewTaskDetail(@PathVariable Long taskId) {
        return "task/detail";
    }
}
