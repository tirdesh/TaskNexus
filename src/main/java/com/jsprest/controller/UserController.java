package com.jsprest.controller;

import com.jsprest.entity.Users;
import com.jsprest.entity.Role;
import com.jsprest.service.UsersService;
import com.jsprest.dao.UserDao;
import com.jsprest.dao.RoleDao;
import com.jsprest.dao.ProjectDao;
import com.jsprest.dao.TaskDao;
import com.jsprest.factory.EntityFactory;
import com.jsprest.factory.MapFactory;
import com.jsprest.service.AuthzService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import jakarta.servlet.http.HttpSession;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.HashSet;
import java.util.Arrays;

@Controller
public class UserController {

    private static final Logger logger = LoggerFactory.getLogger(UserController.class);

    @Autowired
    UsersService userServices;

    @Autowired
    UserDao userDao;

    @Autowired
    RoleDao roleDao;

    @Autowired
    ProjectDao projectDao;

    @Autowired
    TaskDao taskDao;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private EntityFactory entityFactory;

    @Autowired
    private MapFactory mapFactory;

    @Autowired
    private AuthzService authzService;

    @RequestMapping(value = "/login", method = RequestMethod.GET)
    public String loginPage() {
        return "login";
    }

    @RequestMapping(value = "/", method = RequestMethod.GET)
    public String rootRedirect() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.isAuthenticated() && !"anonymousUser".equalsIgnoreCase(String.valueOf(auth.getPrincipal()))) {
            return "redirect:/page";
        }
        return "redirect:/login";
    }

    @RequestMapping(value = "/page", method = RequestMethod.GET)
    public String getPage(org.springframework.ui.Model model) {
        return "home";
    }


    @RequestMapping(value = "/viewUser", method = RequestMethod.GET)
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public String getPage11() {

        return "user/home";
    }


    @RequestMapping(value = "/addUser", method = RequestMethod.GET)
    @PreAuthorize("hasRole('ROLE_ADMIN')")
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


    // Removed GET endpoint for /saveOrUpdate - this was a debug endpoint that shouldn't be exposed
    // Use POST or PATCH methods instead for saving/updating users

    @RequestMapping(value = "/saveOrUpdate", method = {RequestMethod.POST, RequestMethod.PATCH})
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public @ResponseBody
    Map<String, Object> getSaved(@RequestBody Map<String, Object> userData) {
        Map<String, Object> map = mapFactory.createResponseMap();

        try {
            Users user = entityFactory.createUser();

            if (userData.containsKey("userId") && userData.get("userId") != null && !userData.get("userId").toString().isEmpty()) {
                Integer userId = Integer.parseInt(userData.get("userId").toString());
                Users existingUser = userDao.findByIdWithRoles(userId);
                if (existingUser != null) {
                    user = existingUser;
                }
            }

            if (userData.containsKey("name")) {
                user.setUser_name(userData.get("name").toString());
            }

            if (userData.containsKey("email")) {
                String email = userData.get("email") != null ? userData.get("email").toString().trim() : "";
                
                if (email.isEmpty()) {
                    map.put("status", "400");
                    map.put("message", "Email is required");
                    return map;
                }
                
                if (email.length() > 100) {
                    map.put("status", "400");
                    map.put("message", "Email must not exceed 100 characters");
                    return map;
                }
                
                // Basic email format validation
                if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
                    map.put("status", "400");
                    map.put("message", "Please enter a valid email address");
                    return map;
                }
                
                email = email.toLowerCase();
                
                if (user.getUser_id() == null || !email.equals(user.getEmail())) {
                    Users existingUser = userDao.findByEmail(email);
                    if (existingUser != null && !existingUser.getUser_id().equals(user.getUser_id())) {
                        map.put("status", "409");
                        map.put("message", "Email already exists. Please use a different email.");
                        return map;
                    }
                }
                
                user.setEmail(email);
            } else if (user.getUser_id() == null) {
                // Email is required for new users
                map.put("status", "400");
                map.put("message", "Email is required");
                return map;
            }

            if (userData.containsKey("password") && userData.get("password") != null && !userData.get("password").toString().isEmpty()) {
                user.setPassword(passwordEncoder.encode(userData.get("password").toString()));
            }

            if (user.getUser_id() == null) {
                Role userRole = roleDao.findByName("ROLE_USER");
                if (userRole != null) {
                    Set<Role> roles = new HashSet<>();
                    roles.add(userRole);
                    user.setRole(roles);
                } else {
                    user.setRole(entityFactory.createEmptyRoleSet());
                }
            }

            Users savedUser = userServices.saveOrUpdate(user);

            map.put("status", "200");
            map.put("message", "User has been saved successfully");
            map.put("data", savedUser);
        } catch (jakarta.validation.ConstraintViolationException e) {
            logger.error("Validation error saving user", e);
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
            logger.error("Database constraint error saving user", e);
            if (e.getMessage() != null && e.getMessage().contains("email")) {
                map.put("status", "409");
                map.put("message", "Email already exists. Please use a different email.");
            } else {
                map.put("status", "400");
                map.put("message", "Database constraint violation: " + e.getMessage());
            }
        } catch (Exception e) {
            logger.error("Error saving user", e);
            // Check if it's a validation error in the message
            String errorMessage = e.getMessage();
            if (errorMessage != null && errorMessage.contains("ConstraintViolation")) {
                // Try to extract validation messages
                if (errorMessage.contains("Email should be valid")) {
                    map.put("status", "400");
                    map.put("message", "Please enter a valid email address");
                } else if (errorMessage.contains("Email is required")) {
                    map.put("status", "400");
                    map.put("message", "Email is required");
                } else {
                    map.put("status", "400");
                    map.put("message", "Validation failed. Please check your input.");
                }
            } else {
                map.put("status", "500");
                map.put("message", "Error saving user: " + errorMessage);
            }
        }

        return map;
    }

    @RequestMapping(value = "/allRoles", method = RequestMethod.GET)
    @PreAuthorize("hasRole('ROLE_ADMIN')")
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

            List<Role> assignableRoles = roles.stream()
                .filter(r -> r != null && r.getName() != null &&
                    (r.getName().equals("ROLE_PROJECT_MANAGER") || r.getName().equals("ROLE_TEAM_MEMBER")))
                .toList();

            if (assignableRoles != null && !assignableRoles.isEmpty()) {
                map.put("status", "200");
                map.put("message", "Data found");
                map.put("data", assignableRoles);
            } else {
                boolean hasProjectManager = roles.stream().anyMatch(r -> r != null && "ROLE_PROJECT_MANAGER".equals(r.getName()));
                boolean hasTeamMember = roles.stream().anyMatch(r -> r != null && "ROLE_TEAM_MEMBER".equals(r.getName()));

                map.put("status", "404");
                map.put("message", "Required roles not found. Please run SQL: INSERT INTO role (name) VALUES ('ROLE_PROJECT_MANAGER'), ('ROLE_TEAM_MEMBER');");
                map.put("sqlCommand", "INSERT INTO role (name) VALUES ('ROLE_PROJECT_MANAGER'), ('ROLE_TEAM_MEMBER');");
            }
        } catch (Exception e) {
            logger.error("Error loading roles", e);
            map.put("status", "500");
            map.put("message", "Error loading roles: " + e.getMessage());
        }

        return map;
    }


    /**
     * Get list of users for project management.
     * Admins can see all users, Project Managers can see all non-admin users for assigning to projects.
     */
    @RequestMapping(value = "/list", method = RequestMethod.GET)
    @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_USER')")
    public @ResponseBody
    Map<String, Object> getAll(@RequestParam(defaultValue = "1") int page, @RequestParam(defaultValue = "5") int size) {
        Map<String, Object> map = mapFactory.createResponseMap();

        try {
            // Get all users, then filter out admins
            List<Users> allUsers = userDao.findAllPaginated(1, Integer.MAX_VALUE);

            if (allUsers != null) {
                // Filter out admin users (matching frontend logic)
                List<Users> nonAdminUsers = allUsers.stream()
                    .filter(user -> {
                        if (user.getRole() == null || user.getRole().isEmpty()) {
                            return true;
                        }
                        return user.getRole().stream()
                            .noneMatch(role -> role != null && "ROLE_ADMIN".equals(role.getName()));
                    })
                    .toList();
                
                // Calculate total pages based on non-admin user count
                int totalFiltered = nonAdminUsers.size();
                long totalPages = totalFiltered > 0 ? (long) Math.ceil((double) totalFiltered / size) : 0;
                
                // Paginate the filtered list
                int startIndex = (page - 1) * size;
                int endIndex = Math.min(startIndex + size, totalFiltered);
                List<Users> paginatedFiltered = startIndex < totalFiltered 
                    ? nonAdminUsers.subList(startIndex, endIndex)
                    : List.of();

                map.put("status", "200");
                map.put("message", "Data found");
                map.put("data", paginatedFiltered);
                map.put("totalPages", totalPages);
                map.put("currentPage", page);
            } else {
                map.put("status", "404");
                map.put("message", "Data not found");
            }
        } catch (Exception e) {
            logger.error("Error retrieving users", e);
            map.put("status", "500");
            map.put("message", "Error retrieving users: " + e.getMessage());
        }

        return map;
    }

    @RequestMapping(value = "/userList", method = RequestMethod.GET)
    @PreAuthorize("isAuthenticated()")
    public @ResponseBody Map<String, Object> getUserList() {
        Map<String, Object> map = mapFactory.createResponseMap();
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            Users user = userDao.findByEmail(auth.getName());
            if (user == null) {
                map.put("status", "404");
                map.put("message", "User not found");
                return map;
            }
            boolean isAdmin = user.getRole() != null && user.getRole().stream()
                .anyMatch(r -> r != null && r.getName() != null && r.getName().equals("ROLE_ADMIN"));
            
            List<Users> list;
            if (isAdmin) {
                list = userServices.listAll();
            } else {
                list = userServices.findUsersInRelatedProjects(user.getUser_id());
            }

            if (list != null) {
                map.put("status", "200");
                map.put("message", "Data found");
                map.put("data", list);
            } else {
                map.put("status", "404");
                map.put("message", "Data not found");
            }
        } catch (Exception e) {
            logger.error("Error retrieving user list", e);
            map.put("status", "500");
            map.put("message", "Error retrieving user list: " + e.getMessage());
        }
        return map;
    }


    @RequestMapping(value = "/deleteUser", method = RequestMethod.DELETE)
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public @ResponseBody
    Map<String, Object> delete(@RequestParam Integer userId) {
        Map<String, Object> map = mapFactory.createResponseMap();

        try {
            Users user = userDao.findByIdWithRoles(userId);
            if (user == null) {
                map.put("status", "404");
                map.put("message", "User not found");
                return map;
            }
            
            if (user.getRole() != null && !user.getRole().isEmpty()) {
                boolean isAdmin = user.getRole().stream()
                    .anyMatch(role -> role != null && "ROLE_ADMIN".equals(role.getName()));
                if (isAdmin) {
                    map.put("status", "403");
                    map.put("message", "Cannot delete admin users");
                    return map;
                }
            }
            
            userServices.delete(user);
            map.put("status", "200");
            map.put("message", "Your record have been deleted successfully");
        } catch (Exception e) {
            logger.error("Error deleting user with id: {}", userId, e);
            map.put("status", "500");
            map.put("message", "Error deleting user: " + e.getMessage());
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

        // Validate email
        if (email == null || email.trim().isEmpty()) {
            map.put("status", "400");
            map.put("message", "Email is required");
            return map;
        }
        
        email = email.trim().toLowerCase();
        
        if (email.length() > 100) {
            map.put("status", "400");
            map.put("message", "Email must not exceed 100 characters");
            return map;
        }
        
        // Basic email format validation
        if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            map.put("status", "400");
            map.put("message", "Please enter a valid email address");
            return map;
        }

        // Validate password
        if (password == null || password.isEmpty()) {
            map.put("status", "400");
            map.put("message", "Password is required");
            return map;
        }
        
        if (password.length() < 6) {
            map.put("status", "400");
            map.put("message", "Password must be at least 6 characters long");
            return map;
        }
        
        // Reasonable password max length
        if (password.length() > 100) {
            map.put("status", "400");
            map.put("message", "Password must not exceed 100 characters");
            return map;
        }

        if (!password.equals(confirmPassword)) {
            map.put("status", "400");
            map.put("message", "Passwords do not match");
            return map;
        }

        Users user = userDao.findByEmail(email);
        if (user == null) {
            map.put("status", "404");
            map.put("message", "Email not found in system. Please contact admin to add your email first.");
            return map;
        }

        if (user.getPassword() != null && !user.getPassword().isEmpty()) {
            map.put("status", "409");
            map.put("message", "User already registered. Please login instead.");
            return map;
        }

        if (user.getRole() == null || user.getRole().isEmpty()) {
            Role userRole = roleDao.findByName("ROLE_USER");
            if (userRole != null) {
                Set<Role> roles = new HashSet<>();
                roles.add(userRole);
                user.setRole(roles);
            }
        }

        String hashedPassword = passwordEncoder.encode(password);
        user.setPassword(hashedPassword);

        try {
            userDao.save(user);
            map.put("status", "200");
            map.put("message", "Registration successful! You can now login.");
        } catch (jakarta.validation.ConstraintViolationException e) {
            logger.error("Validation error registering user", e);
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
            logger.error("Database constraint error registering user", e);
            if (e.getMessage() != null && e.getMessage().contains("email")) {
                map.put("status", "409");
                map.put("message", "Email already exists. Please login instead.");
            } else {
                map.put("status", "400");
                map.put("message", "Database constraint violation: " + e.getMessage());
            }
        } catch (Exception e) {
            logger.error("Error during registration for email: {}", email, e);
            // Check if it's a validation error in the message
            String errorMessage = e.getMessage();
            if (errorMessage != null && errorMessage.contains("ConstraintViolation")) {
                // Try to extract validation messages
                if (errorMessage.contains("Email should be valid")) {
                    map.put("status", "400");
                    map.put("message", "Please enter a valid email address");
                } else if (errorMessage.contains("Email is required")) {
                    map.put("status", "400");
                    map.put("message", "Email is required");
                } else {
                    map.put("status", "400");
                    map.put("message", "Validation failed. Please check your input.");
                }
            } else {
                map.put("status", "500");
                map.put("message", "Error during registration: " + errorMessage);
            }
        }

        return map;
    }

    @RequestMapping(value = "/currentUser", method = RequestMethod.GET)
    @PreAuthorize("isAuthenticated()")
    public @ResponseBody
    Map<String, Object> getCurrentUser() {
        Map<String, Object> map = mapFactory.createResponseMap();
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.isAuthenticated()) {
            Users user = userDao.findByEmailWithPassword(auth.getName());
            if (user != null) {
                if (user.getRole() != null) {
                    user.getRole().size(); // initialize roles for serialization
                }
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

    @RequestMapping(value = "/dashboard/stats", method = RequestMethod.GET)
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public Map<String, Object> getDashboardStats() {
        Map<String, Object> stats = new HashMap<>();
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            stats.put("status", "401");
            stats.put("message", "User not authenticated");
            return stats;
        }
        Users user = userDao.findByEmail(auth.getName());
        
        if (user == null) {
            stats.put("status", "401");
            stats.put("message", "User not found");
            return stats;
        }
        
        Integer userId = user.getUser_id();
        boolean isAdmin = user.getRole() != null && user.getRole().stream()
            .anyMatch(r -> r != null && "ROLE_ADMIN".equals(r.getName()));

        if (isAdmin) {
            stats.put("totalProjects", projectDao.countAll());
            stats.put("totalTasks", taskDao.countAll());
            stats.put("totalUsers", userServices.countAll());
            stats.put("activeTasks", taskDao.countAllActiveTasks());
            stats.put("myTasks", 0L);
        } else {
            stats.put("totalProjects", projectDao.countProjectsForUser(userId));
            stats.put("totalTasks", taskDao.countTasksForUser(userId));
            stats.put("activeTasks", taskDao.countActiveTasksForUser(userId));
            stats.put("myTasks", taskDao.countTasksByAssignee(userId));
        }
        return stats;
    }

    @RequestMapping(value = "/debug/currentUser", method = RequestMethod.GET)
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public @ResponseBody
    Map<String, Object> debugCurrentUser() {
        Map<String, Object> map = mapFactory.createResponseMap();
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            map.put("status", "401");
            map.put("message", "User not logged in");
            return map;
        }

        Map<String, Object> debug = new java.util.HashMap<>();
        debug.put("principal", auth.getPrincipal());
        debug.put("name", auth.getName());
        debug.put("authorities", auth.getAuthorities());

        Users user = userDao.findByEmailWithPassword(auth.getName());
        if (user != null) {
            if (user.getRole() != null) {
                user.getRole().size(); // force load roles
            }
            debug.put("userEntity", user);
        }

        map.put("status", "200");
        map.put("message", "Debug current user");
        map.put("data", debug);
        return map;
    }
}
