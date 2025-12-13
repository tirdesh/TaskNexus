package com.jsprest.config;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.Collection;

@Component
public class CustomAuthenticationSuccessHandler implements AuthenticationSuccessHandler {

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws IOException, ServletException {
        HttpSession session = request.getSession();
        session.setAttribute("user", authentication.getPrincipal());

        Collection<? extends GrantedAuthority> authorities = authentication.getAuthorities();
        String redirectUrl = "/page"; // Default URL

        // Check for admin role first
        for (GrantedAuthority authority : authorities) {
            if (authority.getAuthority().equals("ROLE_ADMIN")) {
                redirectUrl = "/page"; // Admin dashboard
                break;
            }
        }
        
        // If not admin, all other users have ROLE_USER and should go to home page
        // Project-specific roles (PROJECT_MANAGER, TEAM_MEMBER) are determined by project assignments,
        // not by system roles, so we can't check for them here. Users will see appropriate content
        // based on their project assignments when they navigate to project/task pages.

        response.sendRedirect(request.getContextPath() + redirectUrl);
    }
}
