package com.jsprest.controller;

import com.jsprest.entity.Task;
import com.jsprest.entity.Users;
import com.jsprest.entity.Project;
import com.jsprest.entity.enums.Priority;
import com.jsprest.entity.enums.TaskStatus;
import com.jsprest.dao.TaskDao;
import com.jsprest.dao.UserDao;
import com.jsprest.dao.ProjectDao;
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
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.ResponseBody;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import java.util.List;
import java.util.Map;


@Controller
public class TaskController {

    private static final Logger logger = LoggerFactory.getLogger(TaskController.class);

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

    @Autowired
    private AuthzService authzService;

    @RequestMapping(value = "/saveTask", method = {RequestMethod.POST, RequestMethod.PATCH})
    public @ResponseBody
    Map<String, Object> getSaved(@RequestBody Map<String, Object> taskData) {
        Map<String, Object> map = mapFactory.createResponseMap();

        try {
            Task task = entityFactory.createTask();
            boolean isUpdate = false;
            Long targetProjectId = null;
            
            if (taskData.containsKey("taskId") && taskData.get("taskId") != null && !taskData.get("taskId").toString().isEmpty()) {
                Long taskId = Long.parseLong(taskData.get("taskId").toString());
                Task existingTask = taskDao.findById(taskId);
                if (existingTask != null) {
                    task = existingTask;
                    isUpdate = true;
                    targetProjectId = existingTask.getProject() != null ? existingTask.getProject().getProjectId() : null;
                    if (!authzService.canEditTask(taskId)) {
                        map.put("status", "403");
                        map.put("message", "Not authorized to edit this task");
                        return map;
                    }
                }
            }
            
            if (taskData.containsKey("name")) {
                String name = taskData.get("name") != null ? taskData.get("name").toString().trim() : "";
                if (name.isEmpty()) {
                    map.put("status", "400");
                    map.put("message", "Task name is required");
                    return map;
                }
                if (name.length() < 3) {
                    map.put("status", "400");
                    map.put("message", "Task name must be at least 3 characters long");
                    return map;
                }
                if (name.length() > 200) {
                    map.put("status", "400");
                    map.put("message", "Task name must not exceed 200 characters");
                    return map;
                }
                task.setName(name);
            } else if (task.getTaskId() == null) {
                // Name is required for new tasks
                map.put("status", "400");
                map.put("message", "Task name is required");
                return map;
            }
            
            if (taskData.containsKey("description")) {
                String description = taskData.get("description") != null ? taskData.get("description").toString() : "";
                if (description.length() > 5000) {
                    map.put("status", "400");
                    map.put("message", "Description must not exceed 5000 characters");
                    return map;
                }
                task.setDescription(description);
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
                    LocalDateTime deadline = LocalDateTime.parse(deadlineStr, DateTimeFormatter.ISO_LOCAL_DATE_TIME);
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
                        targetProjectId = projectId;
                    }
                }
            }

            if (!isUpdate) {
                if (targetProjectId == null) {
                    map.put("status", "400");
                    map.put("message", "Project is required for creating a task");
                    return map;
                }
                if (!authzService.canCreateTaskForProject(targetProjectId)) {
                    Users currentUser = authzService.getCurrentUser();
                    String userInfo = currentUser != null ? currentUser.getUser_name() : "Unknown";
                    map.put("status", "403");
                    map.put("message", "Not authorized to create tasks for this project. You must be an Admin, Project Manager, or Team Member of the project.");
                    map.put("debug", "User: " + userInfo + ", Project ID: " + targetProjectId);
                    return map;
                }
                // Set createdBy for new tasks
                Users currentUser = authzService.getCurrentUser();
                if (currentUser != null) {
                    task.setCreatedBy(currentUser);
                }
            }
            
            boolean canAssign = isUpdate ? authzService.canAssignTask(task.getTaskId()) : (targetProjectId != null && authzService.canCreateTaskForProject(targetProjectId));

            if (taskData.containsKey("assignedTo") && taskData.get("assignedTo") != null && canAssign) {
                @SuppressWarnings("unchecked")
                Map<String, Object> userMap = (Map<String, Object>) taskData.get("assignedTo");
                if (userMap.containsKey("user_id")) {
                    Integer userId = Integer.parseInt(userMap.get("user_id").toString());
                    Users user = userDao.findById(userId);
                    if (user == null) {
                        map.put("status", "404");
                        map.put("message", "User not found");
                        return map;
                    }
                    
                    // Validate that all users (including Admin) can only assign to Project Manager or team members
                    Project project = task.getProject();
                    if (project == null) {
                        map.put("status", "400");
                        map.put("message", "Task must belong to a project");
                        return map;
                    }
                    
                    // Check if user is Project Manager or team member
                    boolean isPM = project.getProjectManager() != null && 
                                 project.getProjectManager().getUser_id().equals(userId);
                    boolean isTeamMember = project.getTeamMembers() != null && 
                                          project.getTeamMembers().stream()
                                              .anyMatch(u -> u != null && u.getUser_id() != null && u.getUser_id().equals(userId));
                    
                    if (!isPM && !isTeamMember) {
                        map.put("status", "400");
                        map.put("message", "Can only assign tasks to Project Manager or team members of the project");
                        return map;
                    }
                    
                    task.setAssignedTo(user);
                }
            }

            taskDao.save(task);
            map.put("status", "200");
            map.put("message", "Task has been saved successfully");
        } catch (jakarta.validation.ConstraintViolationException e) {
            logger.error("Validation error saving task", e);
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
        } catch (org.hibernate.exception.ConstraintViolationException e) {
            logger.error("Database constraint error saving task", e);
            map.put("status", "400");
            map.put("message", "Database constraint violation: " + e.getMessage());
        } catch (Exception e) {
            logger.error("Error saving task", e);
            // Check if it's a validation error in the message
            String errorMessage = e.getMessage();
            if (errorMessage != null && errorMessage.contains("ConstraintViolation")) {
                // Try to extract validation messages
                if (errorMessage.contains("Task name is required")) {
                    map.put("status", "400");
                    map.put("message", "Task name is required");
                } else if (errorMessage.contains("must be between")) {
                    map.put("status", "400");
                    map.put("message", "Task name must be between 3 and 200 characters");
                } else if (errorMessage.contains("must not exceed")) {
                    map.put("status", "400");
                    map.put("message", "Description must not exceed 5000 characters");
                } else {
                    map.put("status", "400");
                    map.put("message", "Validation failed. Please check your input.");
                }
            } else {
                map.put("status", "500");
                map.put("message", "Error saving task: " + errorMessage);
            }
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


    @RequestMapping(value = "/allTask", method = RequestMethod.GET)
    public @ResponseBody
    Map<String, Object> getAll(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "5") int size,
            @RequestParam(required = false) Long projectId,
            @RequestParam(required = false) Integer assigneeId,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String priority,
            @RequestParam(required = false, defaultValue = "false") boolean active) {

        Map<String, Object> map = mapFactory.createResponseMap();

        TaskStatus taskStatus = null;
        if (status != null && !status.isEmpty()) {
            try {
                taskStatus = TaskStatus.valueOf(status);
            } catch (IllegalArgumentException e) {
                // Ignore invalid status
            }
        }

        Priority taskPriority = null;
        if (priority != null && !priority.isEmpty()) {
            try {
                taskPriority = Priority.valueOf(priority);
            } catch (IllegalArgumentException e) {
                // Ignore invalid priority
            }
        }

        try {
            // Get all tasks matching filters, then filter by authorization
            // If active=true, exclude COMPLETED tasks
            List<Task> allTasks = taskDao.findFilteredPaginated(1, Integer.MAX_VALUE, projectId, assigneeId, taskStatus, taskPriority, active);
            
            if (allTasks != null) {
                // Filter by authorization
                List<Task> allFiltered = allTasks.stream()
                    .filter(t -> t != null && t.getTaskId() != null && authzService.canViewTask(t.getTaskId()))
                    .toList();
                
                // Calculate total pages based on filtered count
                int totalFiltered = allFiltered.size();
                long totalPages = totalFiltered > 0 ? (long) Math.ceil((double) totalFiltered / size) : 0;
                
                // Paginate the filtered list
                int startIndex = (page - 1) * size;
                int endIndex = Math.min(startIndex + size, totalFiltered);
                List<Task> paginatedFiltered = startIndex < totalFiltered 
                    ? allFiltered.subList(startIndex, endIndex)
                    : List.of();

                // Add permission flags and overdue indicator to each task
                List<Map<String, Object>> tasksWithPermissions = paginatedFiltered.stream()
                    .map(task -> {
                        Map<String, Object> taskMap = new java.util.HashMap<>();
                        taskMap.put("taskId", task.getTaskId());
                        taskMap.put("name", task.getName());
                        taskMap.put("description", task.getDescription());
                        taskMap.put("project", task.getProject());
                        taskMap.put("priority", task.getPriority());
                        taskMap.put("taskStatus", task.getTaskStatus());
                        taskMap.put("assignedTo", task.getAssignedTo());
                        taskMap.put("deadline", task.getDeadline());
                        taskMap.put("createdAt", task.getCreatedAt());
                        taskMap.put("updatedAt", task.getUpdatedAt());
                        // Add permission flags
                        // Ensure boolean values (not null) - team members CANNOT delete tasks
                        taskMap.put("canEdit", Boolean.TRUE.equals(authzService.canEditTask(task.getTaskId())));
                        taskMap.put("canDelete", Boolean.TRUE.equals(authzService.canDeleteTask(task.getTaskId())));
                        // Add overdue indicator
                        boolean isOverdue = task.getDeadline() != null && 
                                          task.getDeadline().isBefore(LocalDateTime.now()) &&
                                          task.getTaskStatus() != TaskStatus.COMPLETED;
                        taskMap.put("isOverdue", isOverdue);
                        return taskMap;
                    })
                    .toList();

                map.put("status", "200");
                map.put("message", "Data found");
                map.put("data", tasksWithPermissions);
                map.put("totalPages", totalPages);
                map.put("currentPage", page);
            } else {
                map.put("status", "404");
                map.put("message", "Task not found");
            }
        } catch (Exception e) {
            logger.error("Error retrieving tasks", e);
            map.put("status", "500");
            map.put("message", "Error retrieving tasks: " + e.getMessage());
        }

        return map;
    }


    /**
     * Delete a task.
     * Only Admin and Project Managers can delete tasks.
     * Project Managers can only delete tasks in projects they manage.
     * Team members CANNOT delete tasks.
     */
    @RequestMapping(value = "/deleteTask", method = RequestMethod.DELETE)
    public @ResponseBody
    Map<String, Object> delete(@RequestParam Long taskId) {
        Map<String, Object> map = mapFactory.createResponseMap();

        try {
            // Authorization check: Only Admin or PM can delete tasks
            // Team members are explicitly excluded
            if (!authzService.canDeleteTask(taskId)) {
                logger.warn("Unauthorized delete attempt for task {} by user {}", taskId, 
                    SecurityContextHolder.getContext().getAuthentication() != null ? 
                    SecurityContextHolder.getContext().getAuthentication().getName() : "unknown");
                map.put("status", "403");
                map.put("message", "Not authorized to delete this task. Only Project Managers and Administrators can delete tasks.");
                return map;
            }
            
            // Use findByIdWithProjectAndAssignedUser to ensure project and project manager are loaded
            Task task = taskDao.findByIdWithProjectAndAssignedUser(taskId);
            if (task == null) {
                map.put("status", "404");
                map.put("message", "Task not found");
                return map;
            }
            
            // Additional defensive check: Verify the task belongs to a project
            // and the user is the PM of that project (or admin)
            // Note: Admins can always delete, so skip this check for admins
            if (!authzService.isAdmin() && task.getProject() != null && task.getProject().getProjectId() != null) {
                if (!authzService.isProjectManager(task.getProject().getProjectId())) {
                    logger.warn("User attempted to delete task {} but is not PM of project {}", 
                        taskId, task.getProject().getProjectId());
                    map.put("status", "403");
                    map.put("message", "Not authorized to delete this task. You must be the Project Manager of this project.");
                    return map;
                }
            }
            
            taskDao.delete(task);
            logger.info("Task {} deleted successfully", taskId);
            map.put("status", "200");
            map.put("message", "Your task has been deleted successfully");
        } catch (Exception e) {
            logger.error("Error deleting task with id: {}", taskId, e);
            map.put("status", "500");
            map.put("message", "Error deleting task: " + e.getMessage());
        }

        return map;
    }

    @RequestMapping(value = "/assignTask", method = RequestMethod.PATCH)
    public @ResponseBody
    Map<String, Object> assignTask(@RequestParam Long taskId, @RequestParam Integer userId) {
        Map<String, Object> map = mapFactory.createResponseMap();

        if (!authzService.canAssignTask(taskId)) {
            map.put("status", "403");
            map.put("message", "Not authorized to assign this task");
            return map;
        }

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

        // Validate that all users (including Admin) can only assign to Project Manager or team members
        Project project = task.getProject();
        if (project == null) {
            map.put("status", "400");
            map.put("message", "Task must belong to a project");
            return map;
        }
        
        // Check if user is Project Manager or team member
        boolean isPM = project.getProjectManager() != null && 
                     project.getProjectManager().getUser_id().equals(userId);
        boolean isTeamMember = project.getTeamMembers() != null && 
                              project.getTeamMembers().stream()
                                  .anyMatch(u -> u != null && u.getUser_id() != null && u.getUser_id().equals(userId));
        
        if (!isPM && !isTeamMember) {
            map.put("status", "400");
            map.put("message", "Can only assign tasks to Project Manager or team members of the project");
            return map;
        }

        task.setAssignedTo(user);
        taskDao.save(task);
        map.put("status", "200");
        map.put("message", "Task has been assigned successfully");

        return map;
    }

    @RequestMapping(value = "/myTasks", method = RequestMethod.GET, produces = "application/json")
    public @ResponseBody
    Map<String, Object> getMyTasks() {
        Map<String, Object> map = mapFactory.createResponseMap();

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
        
        List<Task> myTasks = taskDao.findByAssignedUserId(user.getUser_id());
        
        // Add overdue indicators and permission flags to tasks
        List<Map<String, Object>> tasksWithOverdue = myTasks.stream()
            .map(task -> {
                Map<String, Object> taskMap = new java.util.HashMap<>();
                taskMap.put("taskId", task.getTaskId());
                taskMap.put("name", task.getName());
                taskMap.put("description", task.getDescription());
                taskMap.put("project", task.getProject());
                taskMap.put("priority", task.getPriority());
                taskMap.put("taskStatus", task.getTaskStatus());
                taskMap.put("assignedTo", task.getAssignedTo());
                taskMap.put("deadline", task.getDeadline());
                taskMap.put("createdAt", task.getCreatedAt());
                taskMap.put("updatedAt", task.getUpdatedAt());
                // Add overdue indicator
                boolean isOverdue = task.getDeadline() != null && 
                                  task.getDeadline().isBefore(LocalDateTime.now()) &&
                                  task.getTaskStatus() != TaskStatus.COMPLETED;
                taskMap.put("isOverdue", isOverdue);
                // Add permission flags
                // Ensure boolean values (not null) - team members CANNOT delete tasks
                taskMap.put("canEdit", Boolean.TRUE.equals(authzService.canEditTask(task.getTaskId())));
                taskMap.put("canDelete", Boolean.TRUE.equals(authzService.canDeleteTask(task.getTaskId())));
                return taskMap;
            })
            .toList();
        
        map.put("status", "200");
        map.put("message", "Data found");
        map.put("data", tasksWithOverdue);

        return map;
    }

    @RequestMapping(value = "/updateTaskStatus", method = RequestMethod.PATCH)
    public @ResponseBody
    Map<String, Object> updateTaskStatus(@RequestParam Long taskId, @RequestParam String status) {
        Map<String, Object> map = mapFactory.createResponseMap();

        if (!authzService.canUpdateStatus(taskId)) {
            map.put("status", "403");
            map.put("message", "Not authorized to update this task");
            return map;
        }

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

    @RequestMapping(value = "/task/{taskId}", method = RequestMethod.GET, produces = "application/json")
    public @ResponseBody
    Map<String, Object> getTaskDetail(@PathVariable Long taskId) {
        Map<String, Object> map = mapFactory.createResponseMap();

        try {
            if (!authzService.canViewTask(taskId)) {
                map.put("status", "403");
                map.put("message", "Not authorized to view this task");
                return map;
            }
            Task task = taskDao.findByIdWithProjectAndAssignedUser(taskId);
            if (task != null) {
                // Add overdue indicator
                boolean isOverdue = task.getDeadline() != null && 
                                  task.getDeadline().isBefore(LocalDateTime.now()) &&
                                  task.getTaskStatus() != TaskStatus.COMPLETED;
                // Add permission flags
                // Ensure boolean values (not null) - team members CANNOT delete tasks
                boolean canEdit = Boolean.TRUE.equals(authzService.canEditTask(taskId));
                boolean canDelete = Boolean.TRUE.equals(authzService.canDeleteTask(taskId));
                boolean canCommentOrUpload = Boolean.TRUE.equals(authzService.canCommentOrUpload(taskId));
                
                logger.debug("Task {} permissions - canEdit: {}, canDelete: {}, canCommentOrUpload: {}", 
                    taskId, canEdit, canDelete, canCommentOrUpload);
                
                map.put("status", "200");
                map.put("message", "Data found");
                map.put("data", task);
                map.put("isOverdue", isOverdue);
                map.put("canEdit", canEdit);
                map.put("canDelete", canDelete);
                map.put("canCommentOrUpload", canCommentOrUpload);
            } else {
                map.put("status", "404");
                map.put("message", "Task not found");
            }
        } catch (Exception e) {
            logger.error("Error retrieving task with id: {}", taskId, e);
            map.put("status", "500");
            map.put("message", "Error retrieving task: " + e.getMessage());
        }

        return map;
    }

    @RequestMapping(value = "/myTasks", method = RequestMethod.GET, produces = "text/html")
    public String myTasksPage() {
        return "task/myTasks";
    }

    @RequestMapping(value = "/task/{taskId}", method = RequestMethod.GET, produces = "text/html")
    public String viewTaskDetail(@PathVariable Long taskId) {
        // Authorization check - redirect if not authorized
        if (!authzService.canViewTask(taskId)) {
            return "redirect:/viewTask?error=unauthorized";
        }
        return "task/detail";
    }
}
