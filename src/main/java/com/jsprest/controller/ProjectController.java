package com.jsprest.controller;

import com.jsprest.entity.Project;
import com.jsprest.entity.Users;
import com.jsprest.dao.ProjectDao;
import com.jsprest.dao.UserDao;
import com.jsprest.factory.EntityFactory;
import com.jsprest.factory.MapFactory;
import com.jsprest.service.AuthzService;
import com.jsprest.service.UsersService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.ResponseBody;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.Map;

@Controller
public class ProjectController {

    private static final Logger logger = LoggerFactory.getLogger(ProjectController.class);

    @Autowired
    private ProjectDao projectDao;

    @Autowired
    private UserDao userDao;

    @Autowired
    private EntityFactory entityFactory;

    @Autowired
    private MapFactory mapFactory;

    @Autowired
    private AuthzService authzService;

    @Autowired
    private UsersService usersService;

    @RequestMapping(value = "/saveProject", method = {RequestMethod.POST, RequestMethod.PATCH})
    public @ResponseBody
    Map<String, Object> getSaved(@RequestBody Map<String, Object> projectData) {
        Map<String, Object> map = mapFactory.createResponseMap();

        try {
            Project project = entityFactory.createProject();
            boolean isUpdate = false;
            
            if (projectData.containsKey("projectId") && projectData.get("projectId") != null && !projectData.get("projectId").toString().isEmpty()) {
                Long projectId = Long.parseLong(projectData.get("projectId").toString());
                Project existingProject = projectDao.findById(projectId);
                if (existingProject != null) {
                    project = existingProject;
                    isUpdate = true;
                    if (!authzService.canEditProject(projectId)) {
                        map.put("status", "403");
                        map.put("message", "Not authorized to edit this project");
                        return map;
                    }
                }
            }

            if (!isUpdate && !authzService.canCreateProject()) {
                map.put("status", "403");
                map.put("message", "Not authorized to create projects");
                return map;
            }
            
            if (projectData.containsKey("name")) {
                String name = projectData.get("name") != null ? projectData.get("name").toString().trim() : "";
                if (name.isEmpty()) {
                    map.put("status", "400");
                    map.put("message", "Project name is required");
                    return map;
                }
                if (name.length() < 3) {
                    map.put("status", "400");
                    map.put("message", "Project name must be at least 3 characters long");
                    return map;
                }
                if (name.length() > 100) {
                    map.put("status", "400");
                    map.put("message", "Project name must not exceed 100 characters");
                    return map;
                }
                project.setName(name);
            } else if (project.getProjectId() == null) {
                // Name is required for new projects
                map.put("status", "400");
                map.put("message", "Project name is required");
                return map;
            }
            
            if (projectData.containsKey("description")) {
                String description = projectData.get("description") != null ? projectData.get("description").toString() : "";
                if (description.length() > 5000) {
                    map.put("status", "400");
                    map.put("message", "Description must not exceed 5000 characters");
                    return map;
                }
                project.setDescription(description);
            }
            
            if (projectData.containsKey("projectStatus") && projectData.get("projectStatus") != null) {
                try {
                    com.jsprest.entity.enums.ProjectStatus status = com.jsprest.entity.enums.ProjectStatus.valueOf(projectData.get("projectStatus").toString());
                    project.setProjectStatus(status);
                } catch (IllegalArgumentException e) {
                    // Ignore invalid status
                }
            }
            
            if (projectData.containsKey("projectManager") && projectData.get("projectManager") != null) {
                @SuppressWarnings("unchecked")
                Map<String, Object> managerMap = (Map<String, Object>) projectData.get("projectManager");
                if (managerMap.containsKey("user_id")) {
                    Integer userId = Integer.parseInt(managerMap.get("user_id").toString());
                    Users manager = userDao.findById(userId);
                    if (manager != null) {
                        project.setProjectManager(manager);
                    }
                }
            }
            
            projectDao.save(project);
            map.put("status", "200");
            map.put("message", "Project has been saved successfully");
            map.put("data", project);
        } catch (jakarta.validation.ConstraintViolationException e) {
            logger.error("Validation error saving project", e);
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
            logger.error("Database constraint error saving project", e);
            map.put("status", "400");
            map.put("message", "Database constraint violation: " + e.getMessage());
        } catch (Exception e) {
            logger.error("Error saving project", e);
            // Check if it's a validation error in the message
            String errorMessage = e.getMessage();
            if (errorMessage != null && errorMessage.contains("ConstraintViolation")) {
                // Try to extract validation messages
                if (errorMessage.contains("Project name is required")) {
                    map.put("status", "400");
                    map.put("message", "Project name is required");
                } else if (errorMessage.contains("must be between")) {
                    map.put("status", "400");
                    map.put("message", "Project name must be between 3 and 100 characters");
                } else if (errorMessage.contains("must not exceed")) {
                    map.put("status", "400");
                    map.put("message", "Description must not exceed 5000 characters");
                } else {
                    map.put("status", "400");
                    map.put("message", "Validation failed. Please check your input.");
                }
            } else {
                map.put("status", "500");
                map.put("message", "Error saving project: " + errorMessage);
            }
        }

        return map;
    }


    @RequestMapping(value = "/viewProject", method = RequestMethod.GET)
    public String viewProject() {

        return "project/viewProject";
    }


    @RequestMapping(value = "/addProject", method = RequestMethod.GET)
    public String addProject(@RequestParam(required = false) Long projectId) {
        // If editing an existing project, check edit permission
        if (projectId != null) {
            if (!authzService.canEditProject(projectId)) {
                logger.warn("User attempted to edit project {} without permission", projectId);
                return "redirect:/viewProject?error=unauthorized";
            }
        } else {
            // If creating a new project, check create permission
            if (!authzService.canCreateProject()) {
                logger.warn("User attempted to create project without permission");
                return "redirect:/viewProject?error=unauthorized";
            }
        }
        
        return "project/addProject";
    }


    @RequestMapping(value = "/allProject", method = RequestMethod.GET)
    public @ResponseBody
    Map<String, Object> getAll(
            @RequestParam(defaultValue = "1") int page, 
            @RequestParam(defaultValue = "5") int size,
            @RequestParam(required = false) String search) {
        Map<String, Object> map = mapFactory.createResponseMap();

        try {
            // Get all projects (with search if provided), then filter by authorization
            List<Project> allProjects;
            if (search != null && !search.trim().isEmpty()) {
                logger.info("Searching projects with term: {}", search);
                allProjects = projectDao.searchProjects(search);
                logger.info("Found {} projects from search", allProjects != null ? allProjects.size() : 0);
            } else {
                allProjects = projectDao.findAllPaginated(1, Integer.MAX_VALUE);
            }

            if (allProjects != null) {
                // Filter by authorization
                List<Project> allFiltered = allProjects.stream()
                    .filter(p -> p != null && authzService.canViewProject(p.getProjectId()))
                    .toList();
                
                // Calculate total pages based on filtered count
                int totalFiltered = allFiltered.size();
                long totalPages = totalFiltered > 0 ? (long) Math.ceil((double) totalFiltered / size) : 0;
                
                // Paginate the filtered list
                int startIndex = (page - 1) * size;
                int endIndex = Math.min(startIndex + size, totalFiltered);
                List<Project> paginatedFiltered = startIndex < totalFiltered 
                    ? allFiltered.subList(startIndex, endIndex)
                    : List.of();

                // Add permission flags to each project
                List<Map<String, Object>> projectsWithPermissions = paginatedFiltered.stream()
                    .map(project -> {
                        Map<String, Object> projectMap = new java.util.HashMap<>();
                        projectMap.put("projectId", project.getProjectId());
                        projectMap.put("name", project.getName());
                        projectMap.put("description", project.getDescription());
                        projectMap.put("projectStatus", project.getProjectStatus());
                        projectMap.put("projectManager", project.getProjectManager());
                        projectMap.put("createdAt", project.getCreatedAt());
                        projectMap.put("updatedAt", project.getUpdatedAt());
                        // Add permission flags - explicitly cast to boolean to ensure strict comparison works
                        projectMap.put("canEdit", Boolean.TRUE.equals(authzService.canEditProject(project.getProjectId())));
                        projectMap.put("canDelete", Boolean.TRUE.equals(authzService.canDeleteProject(project.getProjectId())));
                        projectMap.put("canCreateTask", Boolean.TRUE.equals(authzService.canCreateTaskForProject(project.getProjectId())));
                        return projectMap;
                    })
                    .toList();

                map.put("status", "200");
                map.put("message", "Data found");
                map.put("data", projectsWithPermissions);
                map.put("totalPages", totalPages);
                map.put("currentPage", page);

            } else {
                map.put("status", "404");
                map.put("message", "Project not found");
            }
        } catch (Exception e) {
            logger.error("Error retrieving projects", e);
            map.put("status", "500");
            map.put("message", "Error retrieving projects: " + e.getMessage());
        }

        return map;
    }


    /**
     * Delete a project.
     * Only Administrators can delete projects.
     */
    @RequestMapping(value = "/deleteProject", method = RequestMethod.DELETE)
    public @ResponseBody
    Map<String, Object> delete(@RequestParam Long projectId) {
        Map<String, Object> map = mapFactory.createResponseMap();

        try {
            // Authorization check: Only Admin can delete projects
            if (!authzService.canDeleteProject(projectId)) {
                String username = SecurityContextHolder.getContext().getAuthentication() != null ? 
                    SecurityContextHolder.getContext().getAuthentication().getName() : "unknown";
                logger.warn("Unauthorized delete attempt for project {} by user {}", projectId, username);
                map.put("status", "403");
                map.put("message", "Not authorized to delete this project. Only Administrators can delete projects.");
                return map;
            }
            
            // Use findByIdWithTeamMembers to ensure project is loaded with relationships
            // This helps avoid lazy loading issues during deletion
            Project project = projectDao.findByIdWithTeamMembers(projectId);
            if (project == null) {
                map.put("status", "404");
                map.put("message", "Project not found");
                return map;
            }
            
            // Ensure tasks are loaded (they will be cascade deleted)
            // Access the tasks collection to trigger lazy loading if needed
            if (project.getTasks() != null) {
                project.getTasks().size(); // Trigger lazy loading
            }
            
            projectDao.delete(project);
            logger.info("Project {} deleted successfully by admin", projectId);
            map.put("status", "200");
            map.put("message", "Your project has been deleted successfully");
        } catch (Exception e) {
            logger.error("Error deleting project with id: {}", projectId, e);
            map.put("status", "500");
            map.put("message", "Error deleting project: " + e.getMessage());
        }

        return map;
    }

    @RequestMapping(value = "/project/{projectId}", method = RequestMethod.GET, produces = "text/html")
    public String viewProjectDetail(@PathVariable Long projectId) {
        // Authorization check - redirect if not authorized
        if (!authzService.canViewProject(projectId)) {
            return "redirect:/viewProject?error=unauthorized";
        }
        return "project/detail";
    }

    @RequestMapping(value = "/project/{projectId}", method = RequestMethod.GET, produces = "application/json")
    public @ResponseBody
    Map<String, Object> getProjectDetail(@PathVariable Long projectId) {
        Map<String, Object> map = mapFactory.createResponseMap();

        try {
        if (!authzService.canViewProject(projectId)) {
            map.put("status", "403");
            map.put("message", "Not authorized to view this project");
            return map;
        }
        Project project = projectDao.findByIdWithTeamMembers(projectId);
        if (project != null) {
                if (project.getProjectManager() != null) {
                    project.getProjectManager().getUser_name();
                }
                if (project.getTeamMembers() != null) {
                    project.getTeamMembers().size();
                }
                
                java.util.Map<String, Object> projectData = new java.util.HashMap<>();
                projectData.put("projectId", project.getProjectId());
                projectData.put("name", project.getName());
                projectData.put("description", project.getDescription());
                projectData.put("projectStatus", project.getProjectStatus());
                projectData.put("createdAt", project.getCreatedAt());
                projectData.put("updatedAt", project.getUpdatedAt());
                projectData.put("projectManager", project.getProjectManager());
                projectData.put("teamMembers", project.getTeamMembers());
                // Add permission flags - explicitly cast to boolean to ensure strict comparison works
                projectData.put("canEdit", Boolean.TRUE.equals(authzService.canEditProject(projectId)));
                projectData.put("canDelete", Boolean.TRUE.equals(authzService.canDeleteProject(projectId)));
                projectData.put("canManageTeam", Boolean.TRUE.equals(authzService.canManageTeam(projectId)));
                projectData.put("canCreateTask", Boolean.TRUE.equals(authzService.canCreateTaskForProject(projectId)));
                
            map.put("status", "200");
            map.put("message", "Data found");
                map.put("data", projectData);
        } else {
            map.put("status", "404");
            map.put("message", "Project not found");
            }
        } catch (Exception e) {
            logger.error("Error retrieving project with id: {}", projectId, e);
            map.put("status", "500");
            map.put("message", "Error retrieving project: " + e.getMessage());
        }

        return map;
    }

    @RequestMapping(value = "/project/{projectId}/addTeamMember", method = RequestMethod.PATCH)
    public @ResponseBody
    Map<String, Object> addTeamMember(@PathVariable Long projectId, @RequestParam Integer userId) {
        Map<String, Object> map = mapFactory.createResponseMap();

        if (!authzService.canManageTeam(projectId)) {
            map.put("status", "403");
            map.put("message", "Not authorized to manage team members for this project");
            return map;
        }

        Project project = projectDao.findById(projectId);
        if (project == null) {
            map.put("status", "404");
            map.put("message", "Project not found");
            return map;
        }

        Users user = userDao.findById(userId);
        if (user == null) {
            map.put("status", "404");
            map.put("message", "User not found");
            return map;
        }

        // Initialize teamMembers if null
        if (project.getTeamMembers() == null) {
            project.setTeamMembers(new java.util.HashSet<>());
        }
        
        // Check if user is already a team member
        if (project.getTeamMembers().contains(user)) {
            map.put("status", "400");
            map.put("message", "User is already a team member of this project");
            return map;
        }

        project.getTeamMembers().add(user);
        projectDao.save(project);
        map.put("status", "200");
        map.put("message", "Team member has been added successfully");

        return map;
    }

    @RequestMapping(value = "/project/{projectId}/removeTeamMember", method = RequestMethod.DELETE)
    public @ResponseBody
    Map<String, Object> removeTeamMember(@PathVariable Long projectId, @RequestParam Integer userId) {
        Map<String, Object> map = mapFactory.createResponseMap();

        if (!authzService.canManageTeam(projectId)) {
            map.put("status", "403");
            map.put("message", "Not authorized to manage team members for this project");
            return map;
        }

        Project project = projectDao.findById(projectId);
        if (project == null) {
            map.put("status", "404");
            map.put("message", "Project not found");
            return map;
        }

        Users user = userDao.findById(userId);
        if (user == null) {
            map.put("status", "404");
            map.put("message", "User not found");
            return map;
        }

        // Check if trying to remove Project Manager
        if (project.getProjectManager() != null && project.getProjectManager().getUser_id().equals(userId)) {
            map.put("status", "400");
            map.put("message", "Cannot remove Project Manager from team members. Project Manager is always part of the project.");
            return map;
        }

        // Initialize teamMembers if null (shouldn't happen, but defensive programming)
        if (project.getTeamMembers() == null) {
            project.setTeamMembers(new java.util.HashSet<>());
        }

        // Check if this is the last team member (informational, not blocking)
        boolean isLastMember = project.getTeamMembers().size() == 1;

        project.getTeamMembers().remove(user);
        projectDao.save(project);
        
        map.put("status", "200");
        if (isLastMember) {
            map.put("message", "Team member has been removed successfully. This was the last team member in the project.");
        } else {
        map.put("message", "Team member has been removed successfully");
        }

        return map;
    }

    @RequestMapping(value = "/project/{projectId}/teamMembers", method = RequestMethod.GET)
    public @ResponseBody
    Map<String, Object> getTeamMembers(@PathVariable Long projectId) {
        Map<String, Object> map = mapFactory.createResponseMap();

        if (!authzService.canViewProject(projectId)) {
            map.put("status", "403");
            map.put("message", "Not authorized to view this project");
            return map;
        }

        Project project = projectDao.findByIdWithTeamMembers(projectId);
        if (project != null) {
            map.put("status", "200");
            map.put("message", "Data found");
            map.put("data", project.getTeamMembers());
        } else {
            map.put("status", "404");
            map.put("message", "Project not found");
        }

        return map;
    }

    @RequestMapping(value = "/project/{projectId}/availableUsers", method = RequestMethod.GET)
    public @ResponseBody
    Map<String, Object> getAvailableUsersForProject(@PathVariable Long projectId) {
        Map<String, Object> map = mapFactory.createResponseMap();

        if (!authzService.canManageTeam(projectId)) {
            map.put("status", "403");
            map.put("message", "Not authorized to view available users for this project");
            return map;
        }

        Project project = projectDao.findByIdWithTeamMembers(projectId);
        if (project == null) {
            map.put("status", "404");
            map.put("message", "Project not found");
            return map;
        }

        List<Users> nonAdminUsers = usersService.listNonAdmin();
        java.util.Set<Integer> existingIds = new java.util.HashSet<>();
        if (project.getTeamMembers() != null) {
            project.getTeamMembers().forEach(u -> {
                if (u != null && u.getUser_id() != null) {
                    existingIds.add(u.getUser_id());
                }
            });
        }
        if (project.getProjectManager() != null && project.getProjectManager().getUser_id() != null) {
            existingIds.add(project.getProjectManager().getUser_id());
        }

        List<Users> available = nonAdminUsers.stream()
            .filter(u -> u != null && u.getUser_id() != null && !existingIds.contains(u.getUser_id()))
            .toList();

        map.put("status", "200");
        map.put("message", "Data found");
        map.put("data", available);
        return map;
    }

}
