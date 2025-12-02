package com.jsprest.factory;

import com.jsprest.entity.Project;
import com.jsprest.entity.Task;
import com.jsprest.entity.Users;
import com.jsprest.entity.Comment;
import com.jsprest.entity.Attachment;
import com.jsprest.entity.Role;
import org.springframework.stereotype.Component;
import java.util.HashSet;
import java.util.Set;

@Component
public class EntityFactory {

    public Project createProject() {
        return new Project();
    }

    public Task createTask() {
        return new Task();
    }

    public Users createUser() {
        return new Users();
    }

    public Comment createComment() {
        return new Comment();
    }

    public Attachment createAttachment() {
        return new Attachment();
    }

    public Set<Role> createEmptyRoleSet() {
        return new HashSet<Role>();
    }
}

