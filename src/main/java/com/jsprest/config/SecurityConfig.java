package com.jsprest.config;

import com.jsprest.service.UserDetailsServiceImpl;
import jakarta.servlet.DispatcherType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
import org.springframework.security.web.csrf.HttpSessionCsrfTokenRepository;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.security.access.AccessDeniedException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {

    @Autowired
    private UserDetailsServiceImpl userDetailsService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private CustomAuthenticationSuccessHandler customAuthenticationSuccessHandler;

    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder);
        return authProvider;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .sessionManagement(session -> session
                .sessionCreationPolicy(org.springframework.security.config.http.SessionCreationPolicy.IF_REQUIRED)
            )
            .csrf(csrf -> csrf
                .csrfTokenRepository(new HttpSessionCsrfTokenRepository())
                .ignoringRequestMatchers("/login", "/register", "/logout") // Allow login/register/logout without CSRF
            )
            .authorizeHttpRequests(authorize -> authorize
                // Permit internal forwards (for JSP views) and errors
                .dispatcherTypeMatchers(DispatcherType.FORWARD, DispatcherType.ERROR).permitAll()
                // Permit static resources and public pages
                // Note: /admin/** endpoints are protected by @PreAuthorize on AdminController
                .requestMatchers("/login", "/register", "/css/**", "/js/**", "/images/**", "/plugins/**", "/dist/**", "/test/**").permitAll()
                .anyRequest().authenticated()
            )
            .formLogin(form -> form
                .loginPage("/login")
                .successHandler(customAuthenticationSuccessHandler)
                .permitAll()
            )
            .logout(logout -> logout
                .logoutRequestMatcher(new AntPathRequestMatcher("/logout"))
                .logoutSuccessUrl("/login?logout")
                .permitAll())
            .exceptionHandling(exceptions -> exceptions
                .accessDeniedHandler(customAccessDeniedHandler())
            );
        return http.build();
    }
    
    @Bean
    public AccessDeniedHandler customAccessDeniedHandler() {
        return (HttpServletRequest request, HttpServletResponse response, AccessDeniedException accessDeniedException) -> {
            // Check if this is an API request (JSON expected)
            String acceptHeader = request.getHeader("Accept");
            String contentType = request.getContentType();
            boolean isJsonRequest = (acceptHeader != null && acceptHeader.contains("application/json")) ||
                                   (contentType != null && contentType.contains("application/json")) ||
                                   request.getRequestURI().startsWith("/saveTask") ||
                                   request.getRequestURI().startsWith("/tasks/") ||
                                   request.getRequestURI().startsWith("/project/");
            
            if (isJsonRequest) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.setContentType("application/json;charset=UTF-8");
                String message = "Access denied. " + accessDeniedException.getMessage();
                if (accessDeniedException.getMessage() != null && accessDeniedException.getMessage().contains("CSRF")) {
                    message = "CSRF token missing or invalid. Please refresh the page and try again.";
                }
                response.getWriter().write("{\"status\":\"403\",\"message\":\"" + message + "\",\"error\":\"Forbidden\"}");
            } else {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            }
        };
    }
}
