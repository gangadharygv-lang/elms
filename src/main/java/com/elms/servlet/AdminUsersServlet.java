package com.elms.servlet;

import com.elms.dao.UserDAO;
import com.elms.model.User;
import com.elms.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/admin/users")
public class AdminUsersServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        try {
            req.setAttribute("users", userDAO.findAll());
            req.getRequestDispatcher("/views/admin/users.jsp").forward(req, res);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        try {
            User user = new User();
            user.setEmployeeCode(req.getParameter("employeeCode"));
            user.setFullName(req.getParameter("fullName"));
            user.setEmail(req.getParameter("email"));
            user.setPasswordHash(PasswordUtil.sha256(req.getParameter("password")));
            user.setRole(User.Role.valueOf(req.getParameter("role")));
            userDAO.create(user);
            res.sendRedirect(req.getContextPath() + "/admin/users?success=created");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
