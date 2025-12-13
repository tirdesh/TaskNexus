package com.jsprest.controller;

import com.jsprest.entity.Users;
import com.jsprest.entity.Role;
import com.jsprest.service.UsersService;
import com.jsprest.dao.UserDao;
import com.jsprest.dao.RoleDao;
import com.jsprest.factory.EntityFactory;
import com.jsprest.factory.MapFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import jakarta.servlet.http.HttpSession;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Arrays;

@Controller
public class UserController {


    @Autowired
    UsersService userServices;

    @Autowired
    UserDao userDao;

    @Autowired
    RoleDao roleDao;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    @Autowired
    private EntityFactory entityFactory;

    @Autowired
    private MapFactory mapFactory;

    @RequestMapping(value = "/page", method = RequestMethod.GET)
    public String getPage(org.springframework.ui.Model model) {
        return "home";
    }


    @RequestMapping(value = "/viewUser", method = RequestMethod.GET)
    public String getPage11() {

        return "user/home";
    }


    @RequestMapping(value = "/addUser", method = RequestMethod.GET)
    public String addUser(@RequestParam(value = "userId", required = false) Integer userId, 
                          org.springframework.ui.Model model) {
        if (userId != null) {
            Users user = userDao.findByIdWithRoles(userId);
            if (user != null) {
                model.addAttribute("user", user);
            }
        }
        return "user/add";
    }


    @RequestMapping(value = "/saveOrUpdate", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> getSaved(@RequestBody Map<String, Object> userData) {
        Map<String, Object> map = mapFactory.createResponseMap();

        try {
            Users user = entityFactory.createUser();
            
            // Handle existing user update
            if (userData.containsKey("userId") && userData.get("userId") != null && !userData.get("userId").toString().isEmpty()) {
                Integer userId = Integer.parseInt(userData.get("userId").toString());
                Users existingUser = userDao.findByIdWithRoles(userId);
                if (existingUser != null) {
                    user = existingUser;
                }
            }
            
            // Set basic user fields
            if (userData.containsKey("name")) {
                user.setUser_name(userData.get("name").toString());
            }
            
            if (userData.containsKey("email")) {
                user.setEmail(userData.get("email").toString());
            }
            
            // Password is not set by admin - user will register themselves
            // Only update password if explicitly provided (for registration)
            if (userData.containsKey("password") && userData.get("password") != null && !userData.get("password").toString().isEmpty()) {
                // This will be used for user registration
                user.setPassword(userData.get("password").toString());
            }
            
            // Roles are NOT assigned at user creation - they are assigned at project level
            // When a user is assigned as Project Manager or Team Member to a project,
            // that defines their role for that specific project.
            // No need to set roles here - keep existing roles if editing, or empty set for new users
            if (user.getUser_id() == null) {
                // New user - no roles assigned (roles come from project assignments)
                user.setRole(entityFactory.createEmptyRoleSet());
            }
            // For existing users, keep their existing roles (if any) - don't overwrite
            
            // Save user with roles
            Users savedUser = userServices.saveOrUpdate(user);
            
            map.put("status", "200");
            map.put("message", "User has been saved successfully");
            map.put("data", savedUser);
        } catch (Exception e) {
            map.put("status", "500");
            map.put("message", "Error saving user: " + e.getMessage());
            e.printStackTrace();
        }

        return map;
    }

    @RequestMapping(value = "/allRoles", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> getAllRoles() {
        Map<String, Object> map = mapFactory.createResponseMap();

        try {
            List<Role> roles = roleDao.findAll();
            
            if (roles == null || roles.isEmpty()) {
                map.put("status", "404");
                map.put("message", "No roles found in database. Please ensure roles are initialized.");
                return map;
            }
            
            // Filter out ROLE_ADMIN and ROLE_USER (only show PROJECT_MANAGER and TEAM_MEMBER for assignment)
            List<Role> assignableRoles = roles.stream()
                .filter(r -> r != null && r.getName() != null && 
                    (r.getName().equals("ROLE_PROJECT_MANAGER") || r.getName().equals("ROLE_TEAM_MEMBER")))
                .toList();

            if (assignableRoles != null && !assignableRoles.isEmpty()) {
                map.put("status", "200");
                map.put("message", "Data found");
                map.put("data", assignableRoles);
            } else {
                // Check if roles need to be created
                boolean hasProjectManager = roles.stream().anyMatch(r -> r != null && "ROLE_PROJECT_MANAGER".equals(r.getName()));
                boolean hasTeamMember = roles.stream().anyMatch(r -> r != null && "ROLE_TEAM_MEMBER".equals(r.getName()));
                
                // Roles not found - provide clear instructions
                map.put("status", "404");
                map.put("message", "Required roles not found. Please run SQL: INSERT INTO role (name) VALUES ('ROLE_PROJECT_MANAGER'), ('ROLE_TEAM_MEMBER');");
                map.put("sqlCommand", "INSERT INTO role (name) VALUES ('ROLE_PROJECT_MANAGER'), ('ROLE_TEAM_MEMBER');");
            }
        } catch (Exception e) {
            map.put("status", "500");
            map.put("message", "Error loading roles: " + e.getMessage());
            e.printStackTrace();
        }

        return map;
    }


    @RequestMapping(value = "/list", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> getAll(Users users) {
        Map<String, Object> map = mapFactory.createResponseMap();

        List<Users> list = userServices.list();

        if (list != null) {
            map.put("status", "200");
            map.put("message", "Data found");
            map.put("data", list);
        } else {
            map.put("status", "404");
            map.put("message", "Data not found");

        }

        System.out.println(map);
        return map;
    }


    @RequestMapping(value = "/deleteUser", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> delete(Users users) {
        Map<String, Object> map = mapFactory.createResponseMap();

        userServices.delete(users);
        map.put("status", "200");
        map.put("message", "Your record have been deleted successfully");

        System.out.println(map);
        return map;
    }

    @RequestMapping(value = "/userLogin", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> userLogin(@RequestParam String email, @RequestParam String password, HttpSession session) {
        Map<String, Object> map = mapFactory.createResponseMap();

        Users user = userDao.findByEmail(email);
        if (user != null) {
            // Check if user has registered (has password)
            if (user.getPassword() == null || user.getPassword().isEmpty()) {
                map.put("status", "403");
                map.put("message", "Please register first. Your email has been added by admin, but you need to set your password.");
                return map;
            }
            
            // Verify password using BCrypt
            boolean passwordMatches = false;
            if (user.getPassword().startsWith("$2a$") || user.getPassword().startsWith("$2b$") || user.getPassword().startsWith("$2y$")) {
                passwordMatches = passwordEncoder.matches(password, user.getPassword());
            } else {
                // Plain text password (fallback for development)
                passwordMatches = user.getPassword().equals(password);
            }
            
            if (!passwordMatches) {
                map.put("status", "401");
                map.put("message", "Invalid password");
                return map;
            }
            
            // Load user with roles
            Users userWithRoles = userDao.findByIdWithRoles(user.getUser_id());
            if (userWithRoles != null) {
                session.setAttribute("userId", userWithRoles.getUser_id());
                session.setAttribute("userName", userWithRoles.getUser_name());
                session.setAttribute("userEmail", userWithRoles.getEmail());
                session.setAttribute("userRoles", userWithRoles.getRole());
                
                map.put("status", "200");
                map.put("message", "Login successful");
                map.put("data", userWithRoles);
            } else {
                map.put("status", "404");
                map.put("message", "User not found");
            }
        } else {
            map.put("status", "404");
            map.put("message", "User not found with email: " + email + ". Please contact admin to add your email first.");
        }

        return map;
    }
    
    @RequestMapping(value = "/register", method = RequestMethod.GET)
    public String registerPage() {
        return "user/register";
    }
    
    @RequestMapping(value = "/register", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> register(@RequestParam String email, @RequestParam String password, @RequestParam String confirmPassword) {
        Map<String, Object> map = mapFactory.createResponseMap();

        // Validate passwords match
        if (!password.equals(confirmPassword)) {
            map.put("status", "400");
            map.put("message", "Passwords do not match");
            return map;
        }
        
        // Check if email exists in system (must be added by admin first)
        Users user = userDao.findByEmail(email);
        if (user == null) {
            map.put("status", "404");
            map.put("message", "Email not found in system. Please contact admin to add your email first.");
            return map;
        }
        
        // Check if user already registered
        if (user.getPassword() != null && !user.getPassword().isEmpty()) {
            map.put("status", "409");
            map.put("message", "User already registered. Please login instead.");
            return map;
        }
        
        // Hash password and save
        String hashedPassword = passwordEncoder.encode(password);
        user.setPassword(hashedPassword);
        
        try {
            userDao.save(user);
            map.put("status", "200");
            map.put("message", "Registration successful! You can now login.");
        } catch (Exception e) {
            map.put("status", "500");
            map.put("message", "Error during registration: " + e.getMessage());
            e.printStackTrace();
        }

        return map;
    }

    @RequestMapping(value = "/userLogout", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> userLogout(HttpSession session) {
        Map<String, Object> map = mapFactory.createResponseMap();
        session.invalidate();
        map.put("status", "200");
        map.put("message", "Logout successful");
        return map;
    }

    @RequestMapping(value = "/currentUser", method = RequestMethod.POST)
    public @ResponseBody
    Map<String, Object> getCurrentUser(HttpSession session) {
        Map<String, Object> map = mapFactory.createResponseMap();
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId != null) {
            Users user = userDao.findByIdWithRoles(userId);
            if (user != null) {
                map.put("status", "200");
                map.put("message", "User found");
                map.put("data", user);
            } else {
                map.put("status", "404");
                map.put("message", "User not found");
            }
        } else {
            map.put("status", "401");
            map.put("message", "User not logged in");
        }
        return map;
    }
}
