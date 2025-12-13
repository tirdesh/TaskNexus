package com.jsprest.service;

import com.jsprest.entity.Users;
import com.jsprest.dao.UserDao;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UsersServiceImpl implements UsersService {

    @Autowired
    UserDao userDao;

    public Users saveOrUpdate(Users users) {
        return userDao.save(users);
    }

    public List<Users> list() {
        return userDao.findAllNonAdmin();
    }

    public List<Users> listAll() {
        return userDao.findAll();
    }

    public List<Users> listNonAdmin() {
        return userDao.findAllNonAdmin();
    }

    public void delete(Users users) {
// TODO Auto-generated method stub
        userDao.delete(users);
    }

    @Override
    public Long countAll() {
        return userDao.countAll();
    }

    @Override
    public List<Users> findUsersInRelatedProjects(Integer userId) {
        return userDao.findUsersInRelatedProjects(userId);
    }
}
