package com.jsprest.exception;

import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.NoHandlerFoundException;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@ControllerAdvice
public class CustomGlobalExceptionHandler extends ResponseEntityExceptionHandler {

    // error handle for @Valid
    @Override
    protected ResponseEntity<Object> handleMethodArgumentNotValid(MethodArgumentNotValidException ex,
                                                                  HttpHeaders headers,
                                                                  HttpStatusCode status, WebRequest request) {

        Map<String, Object> body = new LinkedHashMap<>();
        //body.put("timestamp", new Date());

        body.put("success", false);
        // body.put("status", status.value());

        //Get all errors
        List<String> errors = ex.getBindingResult()
                .getFieldErrors()
                .stream()
                .map(x -> x.getDefaultMessage())
                .collect(Collectors.toList());

        body.put("message", "Please check validations");
        body.put("data", errors);

        return new ResponseEntity<>(body, headers, status);

    }
    
    // Handle 404 NoHandlerFoundException - only for API requests
    // For HTML requests, let Spring forward to /error which will be handled by CustomErrorController
    @Override
    protected ResponseEntity<Object> handleNoHandlerFoundException(NoHandlerFoundException ex,
                                                                   HttpHeaders headers,
                                                                   HttpStatusCode status,
                                                                   WebRequest request) {
        String requestURL = ex.getRequestURL();
        
        // Check if this is a static resource - if so, return JSON 404
        if (isStaticResource(requestURL)) {
            Map<String, Object> body = new LinkedHashMap<>();
            body.put("type", "about:blank");
            body.put("title", "Not Found");
            body.put("status", HttpStatus.NOT_FOUND.value());
            body.put("detail", "No static resource " + requestURL + ".");
            body.put("instance", requestURL);
            return new ResponseEntity<>(body, headers, status);
        }
        
        // Check if this is an API request (explicitly wants JSON, not HTML)
        String acceptHeader = request.getHeader("Accept");
        boolean isJsonRequest = acceptHeader != null && 
                               acceptHeader.contains(MediaType.APPLICATION_JSON_VALUE) &&
                               !acceptHeader.contains(MediaType.TEXT_HTML_VALUE);
        
        if (isJsonRequest) {
            // Return JSON for API requests
            Map<String, Object> body = new LinkedHashMap<>();
            body.put("type", "about:blank");
            body.put("title", "Not Found");
            body.put("status", HttpStatus.NOT_FOUND.value());
            body.put("detail", "No handler found for " + requestURL + ".");
            body.put("instance", requestURL);
            return new ResponseEntity<>(body, headers, status);
        } else {
            // For HTML page requests, let Spring's default error handling forward to /error
            // This will trigger the CustomErrorController which will show 404.jsp
            return super.handleNoHandlerFoundException(ex, headers, status, request);
        }
    }
    
    /**
     * Check if the request URL is for a static resource
     */
    private boolean isStaticResource(String requestURL) {
        if (requestURL == null) {
            return false;
        }
        
        // Common static resource paths
        return requestURL.startsWith("/css/") ||
               requestURL.startsWith("/js/") ||
               requestURL.startsWith("/images/") ||
               requestURL.startsWith("/plugins/") ||
               requestURL.startsWith("/dist/") ||
               requestURL.startsWith("/assets/") ||
               requestURL.endsWith(".css") ||
               requestURL.endsWith(".js") ||
               requestURL.endsWith(".png") ||
               requestURL.endsWith(".jpg") ||
               requestURL.endsWith(".jpeg") ||
               requestURL.endsWith(".gif") ||
               requestURL.endsWith(".svg") ||
               requestURL.endsWith(".ico") ||
               requestURL.endsWith(".woff") ||
               requestURL.endsWith(".woff2") ||
               requestURL.endsWith(".ttf") ||
               requestURL.endsWith(".eot");
    }

}