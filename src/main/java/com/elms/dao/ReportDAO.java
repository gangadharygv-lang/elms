package com.elms.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * ReportDAO — all analytics queries for the ELMS reporting module.
 *
 * Admin methods query across ALL employees.
 * Manager methods are scoped to the manager's direct reportees (manager_id = ?).
 */
public class ReportDAO {

    // ──────────────────────────────────────────────────────────────
    //  SHARED / ADMIN-WIDE
    // ──────────────────────────────────────────────────────────────

    /** Count of requests grouped by status (all employees). */
    public Map<String, Integer> countByStatus() throws SQLException {
        return countMap("SELECT status, COUNT(*) FROM leave_requests GROUP BY status");
    }

    /** Count of APPROVED requests grouped by leave type code. */
    public Map<String, Integer> countByLeaveType() throws SQLException {
        return countMap(
            "SELECT lt.type_name, COUNT(*) " +
            "FROM leave_requests lr " +
            "JOIN leave_types lt ON lr.leave_type_id = lt.type_id " +
            "WHERE lr.status = 'APPROVED' " +
            "GROUP BY lt.type_name ORDER BY lt.type_name");
    }

    /** Monthly trend of APPROVED leaves for current year. */
    public Map<String, Integer> monthlyApprovedTrend() throws SQLException {
        return countMap(
            "SELECT DATE_FORMAT(start_date, '%b %Y') label, COUNT(*) " +
            "FROM leave_requests " +
            "WHERE status = 'APPROVED' AND YEAR(start_date) = YEAR(CURDATE()) " +
            "GROUP BY MONTH(start_date), DATE_FORMAT(start_date, '%b %Y') " +
            "ORDER BY MONTH(start_date)");
    }

    /** Approved leave days per department. */
    public Map<String, Integer> approvedDaysByDepartment() throws SQLException {
        return countMap(
            "SELECT COALESCE(d.dept_name, 'Unassigned'), " +
            "       CAST(SUM(lr.duration_days) AS UNSIGNED) " +
            "FROM leave_requests lr " +
            "JOIN users u ON lr.user_id = u.user_id " +
            "LEFT JOIN departments d ON u.dept_id = d.dept_id " +
            "WHERE lr.status = 'APPROVED' " +
            "GROUP BY d.dept_name ORDER BY d.dept_name");
    }

    /**
     * KPI summary: total requests, pending, approved, rejected, cancelled,
     * total employees, total leave days taken.
     * Returns a flat map: key -> value.
     */
    public Map<String, Integer> kpiSummary() throws SQLException {
        Map<String, Integer> kpi = new LinkedHashMap<>();
        String sql =
            "SELECT " +
            "  COUNT(*)                                          AS total_requests, " +
            "  SUM(status = 'PENDING')                          AS pending, " +
            "  SUM(status = 'APPROVED')                         AS approved, " +
            "  SUM(status = 'REJECTED')                         AS rejected, " +
            "  SUM(status = 'CANCELLED')                        AS cancelled, " +
            "  (SELECT COUNT(*) FROM users WHERE role = 'EMP')  AS total_employees, " +
            "  CAST(COALESCE(SUM(CASE WHEN status='APPROVED' THEN duration_days END),0) " +
            "       AS UNSIGNED)                                 AS total_days_taken " +
            "FROM leave_requests";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                kpi.put("totalRequests",   rs.getInt("total_requests"));
                kpi.put("pending",         rs.getInt("pending"));
                kpi.put("approved",        rs.getInt("approved"));
                kpi.put("rejected",        rs.getInt("rejected"));
                kpi.put("cancelled",       rs.getInt("cancelled"));
                kpi.put("totalEmployees",  rs.getInt("total_employees"));
                kpi.put("totalDaysTaken",  rs.getInt("total_days_taken"));
            }
        }
        return kpi;
    }

    /**
     * Top 10 employees by total approved leave days.
     * Each row: [fullName, employeeCode, deptName, totalDays]
     */
    public List<Object[]> topLeaveConsumers(int limit) throws SQLException {
        String sql =
            "SELECT u.full_name, u.employee_code, " +
            "       COALESCE(d.dept_name,'Unassigned'), " +
            "       CAST(SUM(lr.duration_days) AS UNSIGNED) AS total " +
            "FROM leave_requests lr " +
            "JOIN users u ON lr.user_id = u.user_id " +
            "LEFT JOIN departments d ON u.dept_id = d.dept_id " +
            "WHERE lr.status = 'APPROVED' " +
            "GROUP BY u.user_id, u.full_name, u.employee_code, d.dept_name " +
            "ORDER BY total DESC LIMIT ?";
        List<Object[]> rows = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    rows.add(new Object[]{
                        rs.getString(1), rs.getString(2),
                        rs.getString(3), rs.getInt(4)
                    });
                }
            }
        }
        return rows;
    }

    /**
     * Per-employee leave summary for all employees.
     * Each row: [fullName, employeeCode, deptName, role,
     *            pending, approved, rejected, totalDaysTaken]
     */
    public List<Object[]> employeeLeaveSummary() throws SQLException {
        String sql =
            "SELECT u.full_name, u.employee_code, " +
            "       COALESCE(d.dept_name,'Unassigned'), u.role, " +
            "       SUM(lr.status='PENDING')  AS pend, " +
            "       SUM(lr.status='APPROVED') AS appr, " +
            "       SUM(lr.status='REJECTED') AS rej, " +
            "       CAST(COALESCE(SUM(CASE WHEN lr.status='APPROVED' " +
            "            THEN lr.duration_days END),0) AS UNSIGNED) AS days " +
            "FROM users u " +
            "LEFT JOIN leave_requests lr ON u.user_id = lr.user_id " +
            "LEFT JOIN departments d ON u.dept_id = d.dept_id " +
            "WHERE u.role = 'EMP' " +
            "GROUP BY u.user_id, u.full_name, u.employee_code, d.dept_name, u.role " +
            "ORDER BY u.full_name";
        List<Object[]> rows = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                rows.add(new Object[]{
                    rs.getString(1), rs.getString(2), rs.getString(3),
                    rs.getString(4),
                    rs.getInt(5), rs.getInt(6), rs.getInt(7), rs.getInt(8)
                });
            }
        }
        return rows;
    }

    /**
     * Leave type breakdown — entitled vs taken for current year (all employees).
     * Each row: [typeName, typeCode, totalEntitled, totalTaken, totalRemaining]
     */
    public List<Object[]> leaveTypeBalanceSummary() throws SQLException {
        String sql =
            "SELECT lt.type_name, lt.type_code, " +
            "       SUM(lb.total_entitled), " +
            "       CAST(SUM(lb.days_taken) AS UNSIGNED), " +
            "       CAST(SUM(lb.days_remaining) AS UNSIGNED) " +
            "FROM leave_balances lb " +
            "JOIN leave_types lt ON lb.leave_type_id = lt.type_id " +
            "WHERE lb.year = YEAR(CURDATE()) " +
            "GROUP BY lt.type_id, lt.type_name, lt.type_code " +
            "ORDER BY lt.type_name";
        List<Object[]> rows = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                rows.add(new Object[]{
                    rs.getString(1), rs.getString(2),
                    rs.getInt(3), rs.getInt(4), rs.getInt(5)
                });
            }
        }
        return rows;
    }

    // ──────────────────────────────────────────────────────────────
    //  MANAGER-SCOPED (only their direct reportees)
    // ──────────────────────────────────────────────────────────────

    /** KPI summary for a manager's team. */
    public Map<String, Integer> kpiSummaryForManager(int managerId) throws SQLException {
        Map<String, Integer> kpi = new LinkedHashMap<>();
        String sql =
            "SELECT " +
            "  COUNT(*)                                                AS total_requests, " +
            "  SUM(lr.status = 'PENDING')                             AS pending, " +
            "  SUM(lr.status = 'APPROVED')                            AS approved, " +
            "  SUM(lr.status = 'REJECTED')                            AS rejected, " +
            "  (SELECT COUNT(*) FROM users WHERE manager_id = ? AND is_active=1) AS team_size, " +
            "  CAST(COALESCE(SUM(CASE WHEN lr.status='APPROVED' " +
            "       THEN lr.duration_days END),0) AS UNSIGNED)        AS total_days_taken " +
            "FROM leave_requests lr " +
            "JOIN users u ON lr.user_id = u.user_id " +
            "WHERE u.manager_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, managerId);
            ps.setInt(2, managerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    kpi.put("totalRequests", rs.getInt("total_requests"));
                    kpi.put("pending",       rs.getInt("pending"));
                    kpi.put("approved",      rs.getInt("approved"));
                    kpi.put("rejected",      rs.getInt("rejected"));
                    kpi.put("teamSize",      rs.getInt("team_size"));
                    kpi.put("totalDaysTaken",rs.getInt("total_days_taken"));
                }
            }
        }
        return kpi;
    }

    /** Status distribution for a manager's team. */
    public Map<String, Integer> countByStatusForManager(int managerId) throws SQLException {
        String sql =
            "SELECT lr.status, COUNT(*) " +
            "FROM leave_requests lr " +
            "JOIN users u ON lr.user_id = u.user_id " +
            "WHERE u.manager_id = ? GROUP BY lr.status";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, managerId);
            return countMapFromPs(ps);
        }
    }

    /** Monthly approved trend for a manager's team (current year). */
    public Map<String, Integer> monthlyTrendForManager(int managerId) throws SQLException {
        String sql =
            "SELECT DATE_FORMAT(lr.start_date, '%b %Y'), COUNT(*) " +
            "FROM leave_requests lr " +
            "JOIN users u ON lr.user_id = u.user_id " +
            "WHERE u.manager_id = ? AND lr.status='APPROVED' " +
            "  AND YEAR(lr.start_date) = YEAR(CURDATE()) " +
            "GROUP BY MONTH(lr.start_date), DATE_FORMAT(lr.start_date,'%b %Y') " +
            "ORDER BY MONTH(lr.start_date)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, managerId);
            return countMapFromPs(ps);
        }
    }

    /** Per-employee breakdown for a manager's team. */
    public List<Object[]> teamLeaveSummary(int managerId) throws SQLException {
        String sql =
            "SELECT u.full_name, u.employee_code, " +
            "       SUM(lr.status='PENDING')  AS pend, " +
            "       SUM(lr.status='APPROVED') AS appr, " +
            "       SUM(lr.status='REJECTED') AS rej, " +
            "       CAST(COALESCE(SUM(CASE WHEN lr.status='APPROVED' " +
            "            THEN lr.duration_days END),0) AS UNSIGNED) AS days " +
            "FROM users u " +
            "LEFT JOIN leave_requests lr ON u.user_id = lr.user_id " +
            "WHERE u.manager_id = ? AND u.is_active = 1 " +
            "GROUP BY u.user_id, u.full_name, u.employee_code " +
            "ORDER BY u.full_name";
        List<Object[]> rows = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, managerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    rows.add(new Object[]{
                        rs.getString(1), rs.getString(2),
                        rs.getInt(3), rs.getInt(4), rs.getInt(5), rs.getInt(6)
                    });
                }
            }
        }
        return rows;
    }

    /** Leave type distribution (approved) for a manager's team. */
    public Map<String, Integer> leaveTypeForManager(int managerId) throws SQLException {
        String sql =
            "SELECT lt.type_name, COUNT(*) " +
            "FROM leave_requests lr " +
            "JOIN users u ON lr.user_id = u.user_id " +
            "JOIN leave_types lt ON lr.leave_type_id = lt.type_id " +
            "WHERE u.manager_id = ? AND lr.status='APPROVED' " +
            "GROUP BY lt.type_name ORDER BY lt.type_name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, managerId);
            return countMapFromPs(ps);
        }
    }

    // ──────────────────────────────────────────────────────────────
    //  HELPERS
    // ──────────────────────────────────────────────────────────────

    private Map<String, Integer> countMap(String sql) throws SQLException {
        Map<String, Integer> map = new LinkedHashMap<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) map.put(rs.getString(1), rs.getInt(2));
        }
        return map;
    }

    private Map<String, Integer> countMapFromPs(PreparedStatement ps) throws SQLException {
        Map<String, Integer> map = new LinkedHashMap<>();
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) map.put(rs.getString(1), rs.getInt(2));
        }
        return map;
    }
}
