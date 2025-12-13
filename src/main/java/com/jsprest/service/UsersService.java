package com.jsprest.service;

import com.jsprest.entity.Users;

import java.util.List;

public interface UsersService {
    Users saveOrUpdate(Users users);

    List<Users> list();

    List<Users> listAll();

    List<Users> listNonAdmin();

    void delete(Users users);

    Long countAll();

    List<Users> findUsersInRelatedProjects(Integer userId);
}
