package com.jsprest.controller;

import org.springframework.boot.web.servlet.error.ErrorController;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.Map;

@Controller
public class CustomErrorController implements ErrorController {

    @RequestMapping(value = "/error", produces = {MediaType.TEXT_HTML_VALUE, MediaType.APPLICATION_JSON_VALUE})
    public Object handleError(HttpServletRequest request) {
        Object status = request.getAttribute(RequestDispatcher.ERROR_STATUS_CODE);
        Integer statusCode = HttpStatus.INTERNAL_SERVER_ERROR.value();
        
        if (status != null) {
            statusCode = Integer.valueOf(status.toString());
        }
        
        // Get the original request URI from error attributes
        String originalRequestURI = (String) request.getAttribute(RequestDispatcher.ERROR_REQUEST_URI);
        if (originalRequestURI == null) {
            originalRequestURI = request.getRequestURI();
        }
        
        // Check if this is a static resource request - if so, return 404 JSON (let Spring handle it)
        String requestURI = originalRequestURI;
        if (requestURI != null && isStaticResource(requestURI)) {
            // For static resources that don't exist, return JSON 404
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("type", "about:blank");
            errorResponse.put("title", "Not Found");
            errorResponse.put("status", HttpStatus.NOT_FOUND.value());
            errorResponse.put("detail", "No static resource " + requestURI + ".");
            errorResponse.put("instance", requestURI);
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(errorResponse);
        }
        
        // Check if this is an API request (JSON expected)
        String acceptHeader = request.getHeader("Accept");
        String contentType = request.getContentType();
        
        // Default to HTML unless we're absolutely certain it's a JSON API request
        // This ensures browser requests get the HTML 404 page
        
        boolean isJsonRequest = false;
        
        // Only treat as JSON if:
        // 1. Accept header explicitly wants JSON AND doesn't want HTML
        // 2. AND the request URI is clearly an API endpoint
        if (requestURI != null && !requestURI.equals("/error")) {
            // Check if it's a known API endpoint
            boolean isKnownApiPath = requestURI.startsWith("/api/") ||
                                    requestURI.startsWith("/saveTask") ||
                                    requestURI.startsWith("/tasks/") ||
                                    requestURI.startsWith("/project/") ||
                                    requestURI.startsWith("/allTask") ||
                                    requestURI.startsWith("/allProject") ||
                                    requestURI.startsWith("/list") ||
                                    requestURI.startsWith("/userList") ||
                                    requestURI.startsWith("/delete") ||
                                    requestURI.startsWith("/assign") ||
                                    requestURI.startsWith("/update") ||
                                    requestURI.startsWith("/currentUser") ||
                                    requestURI.startsWith("/dashboard/stats");
            
            // Check if Accept header wants JSON only (not HTML)
            boolean wantsJsonOnly = acceptHeader != null && 
                                   (acceptHeader.contains(MediaType.APPLICATION_JSON_VALUE) ||
                                    acceptHeader.contains("application/json")) &&
                                   !acceptHeader.contains("text/html");
            
            // Check Content-Type
            boolean hasJsonContentType = contentType != null && 
                                        (contentType.contains(MediaType.APPLICATION_JSON_VALUE) ||
                                         contentType.contains("application/json"));
            
            // Only return JSON if it's a known API path AND explicitly wants JSON
            isJsonRequest = isKnownApiPath && (wantsJsonOnly || hasJsonContentType);
        }
        
        // If Accept header contains text/html, always return HTML
        if (acceptHeader != null && acceptHeader.contains("text/html")) {
            isJsonRequest = false;
        }
        
        if (isJsonRequest) {
            // Return JSON response for API requests
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("type", "about:blank");
            errorResponse.put("title", getErrorTitle(statusCode));
            errorResponse.put("status", statusCode);
            errorResponse.put("detail", getErrorDetail(request, statusCode));
            errorResponse.put("instance", requestURI);
            
            return ResponseEntity.status(statusCode)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(errorResponse);
        } else {
            // Return JSP view for HTML requests
            if (statusCode == HttpStatus.NOT_FOUND.value()) {
                return "404";
            } else if (statusCode == HttpStatus.INTERNAL_SERVER_ERROR.value()) {
                return "404"; // For now, return 404 page for 500 errors too
            } else if (statusCode == HttpStatus.FORBIDDEN.value()) {
                return "404"; // For now, return 404 page for 403 errors too
            }
            
            // Default to 404 for any unhandled errors
            return "404";
        }
    }
    
    private String getErrorTitle(Integer statusCode) {
        if (statusCode == HttpStatus.NOT_FOUND.value()) {
            return "Not Found";
        } else if (statusCode == HttpStatus.INTERNAL_SERVER_ERROR.value()) {
            return "Internal Server Error";
        } else if (statusCode == HttpStatus.FORBIDDEN.value()) {
            return "Forbidden";
        } else if (statusCode == HttpStatus.BAD_REQUEST.value()) {
            return "Bad Request";
        }
        return "Error";
    }
    
    private String getErrorDetail(HttpServletRequest request, Integer statusCode) {
        Object errorMessage = request.getAttribute(RequestDispatcher.ERROR_MESSAGE);
        if (errorMessage != null && !errorMessage.toString().isEmpty()) {
            return errorMessage.toString();
        }
        
        if (statusCode == HttpStatus.NOT_FOUND.value()) {
            String requestURI = request.getRequestURI();
            if (requestURI != null && !requestURI.isEmpty()) {
                return "No static resource " + requestURI + ".";
            }
            return "The requested resource was not found.";
        } else if (statusCode == HttpStatus.INTERNAL_SERVER_ERROR.value()) {
            return "An internal server error occurred.";
        } else if (statusCode == HttpStatus.FORBIDDEN.value()) {
            return "Access denied.";
        }
        
        return "An error occurred.";
    }
    
    /**
     * Check if the request URI is for a static resource
     */
    private boolean isStaticResource(String requestURI) {
        if (requestURI == null) {
            return false;
        }
        
        // Common static resource paths
        return requestURI.startsWith("/css/") ||
               requestURI.startsWith("/js/") ||
               requestURI.startsWith("/images/") ||
               requestURI.startsWith("/plugins/") ||
               requestURI.startsWith("/dist/") ||
               requestURI.startsWith("/assets/") ||
               requestURI.endsWith(".css") ||
               requestURI.endsWith(".js") ||
               requestURI.endsWith(".png") ||
               requestURI.endsWith(".jpg") ||
               requestURI.endsWith(".jpeg") ||
               requestURI.endsWith(".gif") ||
               requestURI.endsWith(".svg") ||
               requestURI.endsWith(".ico") ||
               requestURI.endsWith(".woff") ||
               requestURI.endsWith(".woff2") ||
               requestURI.endsWith(".ttf") ||
               requestURI.endsWith(".eot");
    }
}
