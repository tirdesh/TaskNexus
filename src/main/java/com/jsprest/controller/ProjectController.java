package com.jsprest.controller;

import com.jsprest.entity.Project;
import com.jsprest.entity.Task;
import com.jsprest.entity.Users;
import com.jsprest.dao.ProjectDao;
import com.jsprest.dao.UserDao;
import com.jsprest.factory.EntityFactory;
import com.jsprest.factory.MapFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;
import java.util.Map;

@Controller
public class ProjectController {


    @Autowired
    private ProjectDao projectDao;

    @Autowired
    private UserDao userDao;

    @Autowired
    private EntityFactory entityFactory;

    @Autowired
    private MapFactory mapFactory;

    @RequestMapping(value = "/saveProject", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> getSaved(@RequestBody Map<String, Object> projectData) {
        Map<String, Object> map = mapFactory.createResponseMap();

        try {
            Project project = entityFactory.createProject();
            
            if (projectData.containsKey("projectId") && projectData.get("projectId") != null && !projectData.get("projectId").toString().isEmpty()) {
                Long projectId = Long.parseLong(projectData.get("projectId").toString());
                Project existingProject = projectDao.findById(projectId);
                if (existingProject != null) {
                    project = existingProject;
                }
            }
            
            if (projectData.containsKey("name")) {
                project.setName(projectData.get("name").toString());
            }
            
            if (projectData.containsKey("description")) {
                project.setDescription(projectData.get("description").toString());
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
        } catch (Exception e) {
            map.put("status", "500");
            map.put("message", "Error saving project: " + e.getMessage());
            e.printStackTrace();
        }

        return map;
    }


    @RequestMapping(value = "/viewProject", method = RequestMethod.GET)
    public String viewProject() {

        return "project/viewProject";
    }


    @RequestMapping(value = "/addProject", method = RequestMethod.GET)
    public String addProject() {

        return "project/addProject";
    }


    @RequestMapping(value = "/allProject", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> getAll(Task task) {
        Map<String, Object> map = mapFactory.createResponseMap();

        List<Project> allProject = projectDao.findAll();

        if (allProject != null) {
            map.put("status", "200");
            map.put("message", "Data found");
            map.put("data", allProject);
        } else {
            map.put("status", "404");
            map.put("message", "Project not found");

        }

        System.out.println(map);
        return map;
    }


    @RequestMapping(value = "/deleteProject", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> delete(Project project) {
        Map<String, Object> map = mapFactory.createResponseMap();

        projectDao.delete(project);
        map.put("status", "200");
        map.put("message", "Your project has been deleted successfully");

        System.out.println(map);
        return map;
    }

    @RequestMapping(value = "/project/{projectId}", method = RequestMethod.GET)
    public String viewProjectDetail(@PathVariable Long projectId) {
        return "project/detail";
    }

    @RequestMapping(value = "/project/{projectId}", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> getProjectDetail(@PathVariable Long projectId) {
        Map<String, Object> map = mapFactory.createResponseMap();

        Project project = projectDao.findByIdWithTeamMembers(projectId);
        if (project != null) {
            map.put("status", "200");
            map.put("message", "Data found");
            map.put("data", project);
        } else {
            map.put("status", "404");
            map.put("message", "Project not found");
        }

        return map;
    }

    @RequestMapping(value = "/project/{projectId}/addTeamMember", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> addTeamMember(@PathVariable Long projectId, @RequestParam Integer userId) {
        Map<String, Object> map = mapFactory.createResponseMap();

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

        project.getTeamMembers().add(user);
        projectDao.save(project);
        map.put("status", "200");
        map.put("message", "Team member has been added successfully");

        return map;
    }

    @RequestMapping(value = "/project/{projectId}/removeTeamMember", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> removeTeamMember(@PathVariable Long projectId, @RequestParam Integer userId) {
        Map<String, Object> map = mapFactory.createResponseMap();

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

        project.getTeamMembers().remove(user);
        projectDao.save(project);
        map.put("status", "200");
        map.put("message", "Team member has been removed successfully");

        return map;
    }

    @RequestMapping(value = "/project/{projectId}/teamMembers", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> getTeamMembers(@PathVariable Long projectId) {
        Map<String, Object> map = mapFactory.createResponseMap();

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

}
