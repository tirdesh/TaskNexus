package com.jsprest.controller;

import com.jsprest.entity.Admin;
import com.jsprest.dao.AdminDao;
import com.jsprest.factory.MapFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import jakarta.servlet.http.HttpSession;

import java.util.Map;

@Controller
public class AdminController {

    @Autowired
    private AdminDao adminDao;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    @Autowired
    private MapFactory mapFactory;

    @GetMapping("/")
    public String root() {
        return "redirect:/loginPage";
    }

    @GetMapping("/loginPage")
    public String loginPage(
            @RequestParam(value = "error", required = false) String error,
            @RequestParam(value = "logout", required = false) String logout,
            Model model) {
        
        if (error != null) {
            model.addAttribute("error", "Invalid email or password. Please try again.");
        }
        
        if (logout != null) {
            model.addAttribute("message", "You have been logged out successfully.");
        }
        
        return "login";
    }

    @PostMapping("/adminLogin")
    @ResponseBody
    public Map<String, Object> adminLogin(
            @RequestParam String email,
            @RequestParam String password,
            HttpSession session) {
        Map<String, Object> map = mapFactory.createResponseMap();

        Admin admin = adminDao.findByEmail(email);
        if (admin != null) {
            // Check password using BCrypt
            if (admin.getPassword() != null) {
                boolean passwordMatches = false;
                // If password is BCrypt hashed, verify it
                if (admin.getPassword().startsWith("$2a$") || admin.getPassword().startsWith("$2b$") || admin.getPassword().startsWith("$2y$")) {
                    passwordMatches = passwordEncoder.matches(password, admin.getPassword());
                } else {
                    // Plain text password (fallback for development)
                    passwordMatches = admin.getPassword().equals(password);
                }
                
                if (passwordMatches) {
                    session.setAttribute("adminId", admin.getId());
                    session.setAttribute("adminName", admin.getName());
                    session.setAttribute("adminEmail", admin.getEmail());
                    session.setAttribute("isAdmin", true);
                    
                    map.put("status", "200");
                    map.put("message", "Login successful");
                    map.put("data", admin);
                } else {
                    map.put("status", "401");
                    map.put("message", "Invalid password");
                }
            } else {
                map.put("status", "401");
                map.put("message", "Admin password not set");
            }
        } else {
            map.put("status", "404");
            map.put("message", "Admin not found with email: " + email);
        }

        return map;
    }

    @PostMapping("/adminLogout")
    @ResponseBody
    public Map<String, Object> adminLogout(HttpSession session) {
        Map<String, Object> map = mapFactory.createResponseMap();
        session.invalidate();
        map.put("status", "200");
        map.put("message", "Logout successful");
        return map;
    }

    @GetMapping("/denied")
    public String accessDenied() {
        return "404";
    }

    @GetMapping("/userLogin")
    public String userLoginPage() {
        // Redirect to unified login page
        return "redirect:/loginPage";
    }
}


