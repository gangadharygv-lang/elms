package com.elms.dao;

import com.elms.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {
    public User authenticate(String email, String passwordHash) throws SQLException {
        String sql = "SELECT u.*, d.dept_name FROM users u "
                + "LEFT JOIN departments d ON u.dept_id = d.dept_id "
                + "WHERE u.email = ? AND u.password_hash = ? AND u.is_active = 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, passwordHash);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    public User findById(int userId) throws SQLException {
        String sql = "SELECT u.*, d.dept_name FROM users u "
                + "LEFT JOIN departments d ON u.dept_id = d.dept_id WHERE u.user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    public List<User> findAll() throws SQLException {
        String sql = "SELECT u.*, d.dept_name FROM users u "
                + "LEFT JOIN departments d ON u.dept_id = d.dept_id "
                + "ORDER BY u.role, u.full_name";
        List<User> users = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                users.add(mapRow(rs));
            }
        }
        return users;
    }

    public List<User> findReportees(int managerId) throws SQLException {
        String sql = "SELECT u.*, d.dept_name FROM users u "
                + "LEFT JOIN departments d ON u.dept_id = d.dept_id "
                + "WHERE u.manager_id = ? AND u.is_active = 1 ORDER BY u.full_name";
        List<User> users = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, managerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    users.add(mapRow(rs));
                }
            }
        }
        return users;
    }

    public int create(User user) throws SQLException {
        String sql = "INSERT INTO users(employee_code, full_name, email, password_hash, role, dept_id, manager_id) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, user.getEmployeeCode());
            ps.setString(2, user.getFullName());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getPasswordHash());
            ps.setString(5, user.getRole().name());
            if (user.getDeptId() == null) {
                ps.setNull(6, java.sql.Types.INTEGER);
            } else {
                ps.setInt(6, user.getDeptId());
            }
            if (user.getManagerId() == null) {
                ps.setNull(7, java.sql.Types.INTEGER);
            } else {
                ps.setInt(7, user.getManagerId());
            }
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                return keys.next() ? keys.getInt(1) : 0;
            }
        }
    }

    public void updateBasic(User user) throws SQLException {
        String sql = "UPDATE users SET employee_code = ?, full_name = ?, email = ?, role = ?, is_active = ? "
                + "WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getEmployeeCode());
            ps.setString(2, user.getFullName());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getRole().name());
            ps.setBoolean(5, user.isActive());
            ps.setInt(6, user.getUserId());
            ps.executeUpdate();
        }
    }

    public void updatePassword(int userId, String passwordHash) throws SQLException {
        String sql = "UPDATE users SET password_hash = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, passwordHash);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    public void setActive(int userId, boolean active) throws SQLException {
        String sql = "UPDATE users SET is_active = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, active);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setEmployeeCode(rs.getString("employee_code"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setRole(User.Role.valueOf(rs.getString("role")));
        int deptId = rs.getInt("dept_id");
        u.setDeptId(rs.wasNull() ? null : deptId);
        int managerId = rs.getInt("manager_id");
        u.setManagerId(rs.wasNull() ? null : managerId);
        u.setActive(rs.getBoolean("is_active"));
        u.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        try {
            u.setDepartmentName(rs.getString("dept_name"));
        } catch (SQLException ignored) {
            u.setDepartmentName(null);
        }
        return u;
    }
}
