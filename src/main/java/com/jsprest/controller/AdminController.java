package com.jsprest.controller;

import com.jsprest.dao.ProjectDao;
import com.jsprest.dao.TaskDao;
import com.jsprest.entity.Users;
import com.jsprest.service.UsersService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/admin")
@PreAuthorize("hasRole('ROLE_ADMIN')")
public class AdminController {

    @Autowired
    UsersService usersService;

    @Autowired
    private ProjectDao projectDao;

    @Autowired
    private TaskDao taskDao;

    @RequestMapping(value = "/listUsers", method = RequestMethod.GET)
    @ResponseBody
    public Map<String, Object> getAll() {
        Map<String, Object> map = new HashMap<>();
        List<Users> list = usersService.listAll();
        if (list != null) {
            map.put("status", "200");
            map.put("message", "Data found");
            map.put("data", list);
        } else {
            map.put("status", "404");
            map.put("message", "Data not found");
        }
        return map;
    }

    @RequestMapping(value = "/dashboard-stats", method = RequestMethod.GET)
    @ResponseBody
    public Map<String, Object> getDashboardStats() {
        Map<String, Object> map = new HashMap<>();
        map.put("totalProjects", projectDao.countAll());
        map.put("totalTasks", taskDao.countAll());
        map.put("totalUsers", usersService.countAll());
        return map;
    }
}
