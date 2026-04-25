package com.elms.servlet;

import com.elms.dao.PasswordResetDAO;
import com.elms.dao.UserDAO;
import com.elms.util.EmailUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.security.SecureRandom;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    private final PasswordResetDAO resetDAO = new PasswordResetDAO();
    private final UserDAO userDAO = new UserDAO();

    // ── GET: show form ─────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.getRequestDispatcher("/views/forgot-password.jsp").forward(req, res);
    }

    // ── POST: handle submit ─────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String email = req.getParameter("email");

        if (email == null || email.isBlank()) {
            req.setAttribute("error", "Please enter your email address.");
            req.getRequestDispatcher("/views/forgot-password.jsp").forward(req, res);
            return;
        }

        try {
            int userId = resetDAO.findUserIdByEmail(email.trim().toLowerCase());

            // Always show same response (security)
            if (userId != -1) {

                String token = generateToken();
                resetDAO.createToken(userId, token);

                String resetLink = req.getScheme() + "://" + req.getServerName()
                        + ":" + req.getServerPort()
                        + req.getContextPath()
                        + "/reset-password?token=" + token;

                // ✅ HTML EMAIL BODY
                String body = "<html>"
                        + "<body style='font-family: Arial, sans-serif;'>"
                        + "<h2 style='color:#2c3e50;'>ELMS Password Reset</h2>"
                        + "<p>Hello,</p>"
                        + "<p>You requested a password reset for your ELMS account.</p>"

                        + "<p>"
                        + "<a href='" + resetLink + "' "
                        + "style='display:inline-block;padding:10px 15px;"
                        + "background-color:#28a745;color:white;text-decoration:none;"
                        + "border-radius:5px;'>"
                        + "Reset Password"
                        + "</a>"
                        + "</p>"

                        + "<p>This link is valid for <b>30 minutes</b>.</p>"

                        + "<p style='font-size:12px;color:gray;'>"
                        + "If the button doesn't work, copy this link:<br>"
                        + resetLink
                        + "</p>"

                        + "<p>If you did not request this, please ignore this email.</p>"

                        + "<br>"
                        + "<p>Regards,<br><b>ELMS System</b></p>"

                        + "</body>"
                        + "</html>";

                // ✅ SEND MAIL
                EmailUtil.sendStatusNotification(
                        email,
                        "ELMS - Password Reset Request",
                        body
                );

                // Console backup (for testing)
                System.out.println("=== PASSWORD RESET LINK ===");
                System.out.println(resetLink);
                System.out.println("===========================");
            }

            req.setAttribute("success",
                    "If that email is registered, a reset link has been sent.");
            req.getRequestDispatcher("/views/forgot-password.jsp").forward(req, res);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ── Token generator ─────────────────────────────
    private String generateToken() {
        byte[] bytes = new byte[32];
        new SecureRandom().nextBytes(bytes);

        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }
}