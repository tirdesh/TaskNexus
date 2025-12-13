package com.jsprest.service;

import com.jsprest.dao.ProjectDao;
import com.jsprest.dao.TaskDao;
import com.jsprest.dao.UserDao;
import com.jsprest.entity.Project;
import com.jsprest.entity.Task;
import com.jsprest.entity.Users;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component("authz")
public class AuthzService {

    @Autowired
    private UserDao userDao;

    @Autowired
    private ProjectDao projectDao;

    @Autowired
    private TaskDao taskDao;

    public Users getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            return null;
        }
        String email = auth.getName();
        return userDao.findByEmail(email);
    }

    public boolean isAdmin() {
        Users user = getCurrentUser();
        if (user == null || user.getRole() == null) {
            return false;
        }
        return user.getRole().stream().anyMatch(r -> r != null && "ROLE_ADMIN".equals(r.getName()));
    }

    public boolean isProjectManager(Long projectId) {
        if (projectId == null) {
            return false;
        }
        if (isAdmin()) {
            return true;
        }
        Users user = getCurrentUser();
        if (user == null) {
            return false;
        }
        // Use findByIdWithTeamMembers to ensure project manager is fetched
        // (it includes LEFT JOIN FETCH p.projectManager)
        Project project = projectDao.findByIdWithTeamMembers(projectId);
        return project != null
            && project.getProjectManager() != null
            && user.getUser_id().equals(project.getProjectManager().getUser_id());
    }

    public boolean isProjectMember(Long projectId) {
        if (projectId == null) {
            return false;
        }
        if (isAdmin()) {
            return true;
        }
        Users user = getCurrentUser();
        if (user == null) {
            return false;
        }
        Project project = projectDao.findByIdWithTeamMembers(projectId);
        if (project == null) {
            return false;
        }
        if (project.getTeamMembers() == null || project.getTeamMembers().isEmpty()) {
            return false;
        }
        boolean isMember = project.getTeamMembers().stream()
            .anyMatch(u -> u != null && u.getUser_id() != null && user.getUser_id().equals(u.getUser_id()));
        return isMember;
    }

    public boolean canViewProject(Long projectId) {
        return isAdmin() || isProjectManager(projectId) || isProjectMember(projectId);
    }

    public boolean canEditProject(Long projectId) {
        return isAdmin() || isProjectManager(projectId);
    }

    public boolean canCreateProject() {
        return isAdmin();
    }

    public boolean canDeleteProject(Long projectId) {
        return isAdmin();
    }

    public boolean isTaskAssignee(Long taskId) {
        if (taskId == null) {
            return false;
        }
        if (isAdmin()) {
            return true;
        }
        Users user = getCurrentUser();
        if (user == null) {
            return false;
        }
        Task task = taskDao.findByIdWithProjectAndAssignedUser(taskId);
        return task != null
            && task.getAssignedTo() != null
            && user.getUser_id().equals(task.getAssignedTo().getUser_id());
    }

    public boolean isProjectManagerForTask(Long taskId) {
        if (taskId == null) {
            return false;
        }
        if (isAdmin()) {
            return true;
        }
        Task task = taskDao.findByIdWithProjectAndAssignedUser(taskId);
        if (task == null || task.getProject() == null) {
            return false;
        }
        return isProjectManager(task.getProject().getProjectId());
    }

    public boolean isProjectMemberForTask(Long taskId) {
        if (taskId == null) {
            return false;
        }
        Task task = taskDao.findByIdWithProjectAndAssignedUser(taskId);
        if (task == null || task.getProject() == null) {
            return false;
        }
        return isProjectMember(task.getProject().getProjectId());
    }

    public boolean canViewTask(Long taskId) {
        return isAdmin() || isProjectManagerForTask(taskId) || isProjectMemberForTask(taskId) || isTaskAssignee(taskId);
    }

    public boolean canEditTask(Long taskId) {
        return isAdmin() || isProjectManagerForTask(taskId) || isTaskAssignee(taskId);
    }

    /**
     * Allows team members to comment and upload files, but not edit the task itself.
     * This is more permissive than canEditTask() to allow collaboration.
     */
    public boolean canCommentOrUpload(Long taskId) {
        // Allow Admin, Project Manager, Task Assignee, and Team Members
        boolean isPM = isProjectManagerForTask(taskId);
        boolean isAssignee = isTaskAssignee(taskId);
        boolean isMember = isProjectMemberForTask(taskId);
        return isAdmin() || isPM || isAssignee || isMember;
    }

    public boolean canUpdateStatus(Long taskId) {
        return canEditTask(taskId);
    }

    public boolean canAssignTask(Long taskId) {
        return isAdmin() || isProjectManagerForTask(taskId) || isTaskAssignee(taskId);
    }

    public boolean canAssignTaskForProject(Long projectId) {
        return isAdmin() || isProjectManager(projectId);
    }

    public boolean canCreateTaskForProject(Long projectId) {
        // Allow Admin, Project Manager, and Team Members to create tasks
        return isAdmin() || isProjectManager(projectId) || isProjectMember(projectId);
    }

    /**
     * Determines if the current user can delete a task.
     * Only Admin and Project Managers can delete tasks.
     * Project Managers can only delete tasks in projects they manage.
     * Team members CANNOT delete tasks.
     * 
     * @param taskId The ID of the task to check
     * @return true if user is Admin or PM of the project containing the task, false otherwise
     */
    public boolean canDeleteTask(Long taskId) {
        if (taskId == null) {
            return false;
        }
        // Only Admin or Project Manager can delete tasks
        // Team members are explicitly excluded
        return isAdmin() || isProjectManagerForTask(taskId);
    }

    public boolean canManageTeam(Long projectId) {
        return isAdmin() || isProjectManager(projectId);
    }

    public boolean canViewUsersPage() {
        return isAdmin();
    }
}

