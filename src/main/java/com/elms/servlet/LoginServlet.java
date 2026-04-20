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
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            res.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        req.getRequestDispatcher("/views/login.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String email = value(req.getParameter("email"));
        String password = value(req.getParameter("password"));

        if (email.isEmpty() || password.isEmpty()) {
            req.setAttribute("error", "Email and password are required.");
            req.getRequestDispatcher("/views/login.jsp").forward(req, res);
            return;
        }

        try {
            User user = userDAO.authenticate(email, PasswordUtil.sha256(password));
            if (user == null) {
                req.setAttribute("error", "Invalid credentials. Please retry.");
                req.getRequestDispatcher("/views/login.jsp").forward(req, res);
                return;
            }

            HttpSession old = req.getSession(false);
            if (old != null) {
                old.invalidate();
            }
            HttpSession session = req.getSession(true);
            session.setAttribute("user", user);
            session.setMaxInactiveInterval(30 * 60);
            auditLogDAO.log("USER", user.getUserId(), "LOGIN", user.getUserId(),
                    null, "Successful login", req.getRemoteAddr());
            res.sendRedirect(req.getContextPath() + "/dashboard");
        } catch (Exception e) {
            req.setAttribute("error", "System error: " + e.getMessage());
            req.getRequestDispatcher("/views/login.jsp").forward(req, res);
        }
    }

    private String value(String input) {
        return input == null ? "" : input.trim();
    }
}
