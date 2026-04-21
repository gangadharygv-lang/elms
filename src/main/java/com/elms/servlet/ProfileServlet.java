package com.elms.servlet;

import com.elms.dao.AuditLogDAO;
import com.elms.dao.UserDAO;
import com.elms.model.User;
import com.elms.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        try {
            req.setAttribute("pageTitle", "My Profile");
            req.setAttribute("contentPage", "/views/common/profile.jsp");
            req.getRequestDispatcher("/views/common/layout.jsp").forward(req, res);
        } catch (Exception e) {
            showError(res, e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login?timeout=true");
            return;
        }

        User sessionUser = (User) session.getAttribute("user");
        String action = req.getParameter("action");

        try {
            if ("updateProfile".equals(action)) {
                handleUpdateProfile(req, res, session, sessionUser);
            } else if ("changePassword".equals(action)) {
                handleChangePassword(req, res, session, sessionUser);
            } else {
                res.sendRedirect(req.getContextPath() + "/profile");
            }
        } catch (Exception e) {
            showError(res, e);
        }
    }

    private void handleUpdateProfile(HttpServletRequest req, HttpServletResponse res,
                                     HttpSession session, User sessionUser) throws Exception {
        String fullName = req.getParameter("fullName");
        String email    = req.getParameter("email");

        if (fullName == null || fullName.isBlank() || email == null || email.isBlank()) {
            session.setAttribute("flashKey", "error");
            session.setAttribute("flashMsg", "Name and email are required.");
            res.sendRedirect(req.getContextPath() + "/profile");
            return;
        }

        User dbUser = userDAO.findById(sessionUser.getUserId());
        String oldValue = "fullName=" + dbUser.getFullName();
        dbUser.setFullName(fullName.trim());
        userDAO.updateBasic(dbUser);

        User refreshed = userDAO.findById(sessionUser.getUserId());
        session.setAttribute("user", refreshed);

        auditLogDAO.log("USER", dbUser.getUserId(), "PROFILE_UPDATED",
                dbUser.getUserId(), oldValue,
                "fullName=" + fullName.trim() + " | email=" + email.trim(),
                req.getRemoteAddr());

        session.setAttribute("flashKey", "profileSuccess");
        session.setAttribute("flashMsg", "Profile updated successfully.");
        res.sendRedirect(req.getContextPath() + "/profile");
    }

    private void handleChangePassword(HttpServletRequest req, HttpServletResponse res,
                                      HttpSession session, User sessionUser) throws Exception {
        String currentPassword = req.getParameter("currentPassword");
        String newPassword     = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        if (currentPassword == null || newPassword == null || confirmPassword == null
                || currentPassword.isBlank() || newPassword.isBlank() || confirmPassword.isBlank()) {
            session.setAttribute("flashKey", "pwdError");
            session.setAttribute("flashMsg", "All password fields are required.");
            res.sendRedirect(req.getContextPath() + "/profile");
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            session.setAttribute("flashKey", "pwdError");
            session.setAttribute("flashMsg", "New passwords do not match.");
            res.sendRedirect(req.getContextPath() + "/profile");
            return;
        }

        if (newPassword.length() < 6) {
            session.setAttribute("flashKey", "pwdError");
            session.setAttribute("flashMsg", "New password must be at least 6 characters.");
            res.sendRedirect(req.getContextPath() + "/profile");
            return;
        }

        User dbUser = userDAO.findById(sessionUser.getUserId());
        if (!dbUser.getPasswordHash().equals(PasswordUtil.sha256(currentPassword))) {
            session.setAttribute("flashKey", "pwdError");
            session.setAttribute("flashMsg", "Current password is incorrect.");
            res.sendRedirect(req.getContextPath() + "/profile");
            return;
        }

        userDAO.updatePassword(dbUser.getUserId(), PasswordUtil.sha256(newPassword));
        auditLogDAO.log("USER", dbUser.getUserId(), "PASSWORD_CHANGED",
                dbUser.getUserId(), null, "Self-service password change", req.getRemoteAddr());

        session.setAttribute("flashKey", "pwdSuccess");
        session.setAttribute("flashMsg", "Password changed successfully.");
        res.sendRedirect(req.getContextPath() + "/profile");
    }

    // ── Prints the real exception to the browser so you can see what's wrong ──
    private void showError(HttpServletResponse res, Exception e) throws IOException {
        res.setContentType("text/html;charset=UTF-8");
        res.setStatus(500);
        PrintWriter out = res.getWriter();
        out.println("<h2 style='color:red'>ProfileServlet Error</h2>");
        out.println("<pre>");
        e.printStackTrace(out);
        out.println("</pre>");
    }
}