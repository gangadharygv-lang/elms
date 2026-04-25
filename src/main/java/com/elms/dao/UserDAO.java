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

    /** Assigns (or clears) the manager for an employee. */
    public void assignManager(int userId, Integer managerId) throws SQLException {
        String sql = "UPDATE users SET manager_id = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (managerId == null) {
                ps.setNull(1, java.sql.Types.INTEGER);
            } else {
                ps.setInt(1, managerId);
            }
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    /** Returns all active users with role MGR — used to populate the manager dropdown. */
    public List<User> findManagers() throws SQLException {
        String sql = "SELECT u.*, d.dept_name FROM users u "
                + "LEFT JOIN departments d ON u.dept_id = d.dept_id "
                + "WHERE u.role = 'MGR' AND u.is_active = 1 ORDER BY u.full_name";
        List<User> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    /**
     * Returns all departments as a Map of dept_id -> dept_name.
     * Kept simple — no separate Department model needed.
     */
    public java.util.Map<Integer, String> findAllDepartments() throws SQLException {
        String sql = "SELECT dept_id, dept_name FROM departments ORDER BY dept_name";
        java.util.Map<Integer, String> map = new java.util.LinkedHashMap<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getInt("dept_id"), rs.getString("dept_name"));
            }
        }
        return map;
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

    /**
     * Generates the next unique employee code for the given role.
     * Format:  EMP + 5-digit zero-padded number  (e.g. EMP00042)
     *          MGR + 5-digit                      (e.g. MGR00007)
     *          ADM + 5-digit                      (e.g. ADM00001)
     *
     * Finds the highest existing numeric suffix for that prefix and increments it.
     * Safe for concurrent use because the UNIQUE constraint on employee_code will
     * cause a duplicate-key error if two requests race — the servlet should retry
     * or surface the error.
     */
    public String generateNextCode(User.Role role) throws SQLException {
        String prefix;
        if (role == User.Role.MGR) {
            prefix = "MGR";
        } else if (role == User.Role.ADMIN) {
            prefix = "ADM";
        } else {
            prefix = "EMP";
        }
        // Extract the numeric part of all codes that match this prefix and get the max
        String sql = "SELECT MAX(CAST(SUBSTRING(employee_code, ?) AS UNSIGNED)) "
                + "FROM users WHERE employee_code LIKE ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, prefix.length() + 1);          // substring start position (1-based)
            ps.setString(2, prefix + "%");
            try (ResultSet rs = ps.executeQuery()) {
                int next = rs.next() ? rs.getInt(1) + 1 : 1;
                if (rs.wasNull()) next = 1;              // no rows yet for this prefix
                return String.format("%s%05d", prefix, next);
            }
        }
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

    /**
     * Changes a user's role and re-generates their employee code to match the new
     * role prefix (EMP#####, MGR#####, ADM#####).
     * Both columns are updated in a single statement so they are always in sync.
     */
    public void updateRole(int userId, User.Role newRole, String newCode) throws SQLException {
        String sql = "UPDATE users SET role = ?, employee_code = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newRole.name());
            ps.setString(2, newCode);
            ps.setInt(3, userId);
            ps.executeUpdate();
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
