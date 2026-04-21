package com.elms.dao;

import java.sql.*;
import java.time.LocalDateTime;

public class PasswordResetDAO {

    /** Store a reset token valid for 30 minutes. */
    public void createToken(int userId, String token) throws SQLException {
        // Delete any existing unused token for this user first
        String del = "DELETE FROM password_reset_tokens WHERE user_id = ?";
        String ins = "INSERT INTO password_reset_tokens (user_id, token, expires_at) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(del)) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement(ins)) {
                ps.setInt(1, userId);
                ps.setString(2, token);
                ps.setTimestamp(3, Timestamp.valueOf(LocalDateTime.now().plusMinutes(30)));
                ps.executeUpdate();
            }
        }
    }

    /**
     * Validate token. Returns the user_id if valid and not expired, -1 otherwise.
     */
    public int validateToken(String token) throws SQLException {
        String sql = "SELECT user_id, expires_at, used FROM password_reset_tokens WHERE token = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return -1;
                if (rs.getBoolean("used")) return -1;
                LocalDateTime expires = rs.getTimestamp("expires_at").toLocalDateTime();
                if (LocalDateTime.now().isAfter(expires)) return -1;
                return rs.getInt("user_id");
            }
        }
    }

    /** Mark token as used after successful reset. */
    public void markUsed(String token) throws SQLException {
        String sql = "UPDATE password_reset_tokens SET used = 1 WHERE token = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.executeUpdate();
        }
    }

    /** Find user_id by email (active users only). Returns -1 if not found. */
    public int findUserIdByEmail(String email) throws SQLException {
        String sql = "SELECT user_id FROM users WHERE email = ? AND is_active = 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("user_id") : -1;
            }
        }
    }
}