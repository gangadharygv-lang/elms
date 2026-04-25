package com.elms.servlet;

import com.elms.dao.PasswordResetDAO;
import com.elms.dao.UserDAO;
import com.elms.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {

    private final PasswordResetDAO resetDAO = new PasswordResetDAO();
    private final UserDAO userDAO = new UserDAO();

    // ── GET: show reset form (validate token first) ──────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String token = req.getParameter("token");
        if (token == null || token.isBlank()) {
            req.setAttribute("error", "Invalid or missing reset link.");
            req.getRequestDispatcher("/views/reset-password.jsp").forward(req, res);
            return;
        }

        try {
            int userId = resetDAO.validateToken(token);
            if (userId == -1) {
                req.setAttribute("error", "This reset link is invalid or has expired. Please request a new one.");
                req.getRequestDispatcher("/views/reset-password.jsp").forward(req, res);
                return;
            }
            // Token is valid — show the form
            req.setAttribute("token", token);
            req.getRequestDispatcher("/views/reset-password.jsp").forward(req, res);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ── POST: save the new password ──────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String token          = req.getParameter("token");
        String newPassword    = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        // Re-validate token on POST too
        try {
            if (token == null || token.isBlank()) {
                req.setAttribute("error", "Invalid reset link.");
                req.getRequestDispatcher("/views/reset-password.jsp").forward(req, res);
                return;
            }

            int userId = resetDAO.validateToken(token);
            if (userId == -1) {
                req.setAttribute("error", "This reset link is invalid or has expired. Please request a new one.");
                req.getRequestDispatcher("/views/reset-password.jsp").forward(req, res);
                return;
            }

            if (newPassword == null || newPassword.isBlank()
                    || confirmPassword == null || confirmPassword.isBlank()) {
                req.setAttribute("error", "Both password fields are required.");
                req.setAttribute("token", token);
                req.getRequestDispatcher("/views/reset-password.jsp").forward(req, res);
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                req.setAttribute("error", "Passwords do not match.");
                req.setAttribute("token", token);
                req.getRequestDispatcher("/views/reset-password.jsp").forward(req, res);
                return;
            }

            if (newPassword.length() < 6) {
                req.setAttribute("error", "Password must be at least 6 characters.");
                req.setAttribute("token", token);
                req.getRequestDispatcher("/views/reset-password.jsp").forward(req, res);
                return;
            }

            userDAO.updatePassword(userId, PasswordUtil.sha256(newPassword));
            resetDAO.markUsed(token);

            // Redirect to login with success message
            res.sendRedirect(req.getContextPath() + "/login?reset=success");

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}