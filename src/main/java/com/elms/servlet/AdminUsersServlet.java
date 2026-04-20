package com.elms.servlet;

import com.elms.dao.AuditLogDAO;
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
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

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
            User admin = (User) req.getSession().getAttribute("user");
            String action = req.getParameter("action");
            if ("update".equals(action)) {
                updateUser(req, admin);
                res.sendRedirect(req.getContextPath() + "/admin/users?success=updated");
            } else if ("toggle".equals(action)) {
                toggleUser(req, admin);
                res.sendRedirect(req.getContextPath() + "/admin/users?success=status-updated");
            } else {
                createUser(req, admin);
                res.sendRedirect(req.getContextPath() + "/admin/users?success=created");
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private void createUser(HttpServletRequest req, User admin) throws Exception {
        User user = new User();
        user.setEmployeeCode(req.getParameter("employeeCode"));
        user.setFullName(req.getParameter("fullName"));
        user.setEmail(req.getParameter("email"));
        user.setPasswordHash(PasswordUtil.sha256(req.getParameter("password")));
        user.setRole(User.Role.valueOf(req.getParameter("role")));
        int userId = userDAO.create(user);
        auditLogDAO.log("USER", userId, "CREATED", admin.getUserId(),
                null, user.getEmail() + " | role=" + user.getRole(), req.getRemoteAddr());
    }

    private void updateUser(HttpServletRequest req, User admin) throws Exception {
        User user = new User();
        user.setUserId(Integer.parseInt(req.getParameter("userId")));
        user.setEmployeeCode(req.getParameter("employeeCode"));
        user.setFullName(req.getParameter("fullName"));
        user.setEmail(req.getParameter("email"));
        user.setRole(User.Role.valueOf(req.getParameter("role")));
        user.setActive("1".equals(req.getParameter("active")));
        userDAO.updateBasic(user);

        String password = req.getParameter("password");
        if (password != null && !password.isBlank()) {
            userDAO.updatePassword(user.getUserId(), PasswordUtil.sha256(password));
        }

        auditLogDAO.log("USER", user.getUserId(), "UPDATED", admin.getUserId(),
                null, user.getEmail() + " | role=" + user.getRole()
                        + " | active=" + user.isActive(), req.getRemoteAddr());
    }

    private void toggleUser(HttpServletRequest req, User admin) throws Exception {
        int userId = Integer.parseInt(req.getParameter("userId"));
        boolean active = "1".equals(req.getParameter("active"));
        if (userId == admin.getUserId() && !active) {
            throw new ServletException("Administrators cannot deactivate their own account.");
        }
        userDAO.setActive(userId, active);
        auditLogDAO.log("USER", userId, active ? "ACTIVATED" : "DEACTIVATED",
                admin.getUserId(), null, "active=" + active, req.getRemoteAddr());
    }
}
