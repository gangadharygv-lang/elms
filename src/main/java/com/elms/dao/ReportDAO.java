package com.elms.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;

public class ReportDAO {
    public Map<String, Integer> countByStatus() throws SQLException {
        String sql = "SELECT status, COUNT(*) total FROM leave_requests GROUP BY status";
        return countMap(sql);
    }

    public Map<String, Integer> countByLeaveType() throws SQLException {
        String sql = "SELECT lt.type_code, COUNT(*) total FROM leave_requests lr "
                + "JOIN leave_types lt ON lr.leave_type_id = lt.type_id "
                + "WHERE lr.status = 'APPROVED' GROUP BY lt.type_code ORDER BY lt.type_code";
        return countMap(sql);
    }

    public Map<String, Integer> countByDepartment() throws SQLException {
        String sql = "SELECT COALESCE(d.dept_name, 'Unassigned') label, COUNT(*) total "
                + "FROM leave_requests lr JOIN users u ON lr.user_id = u.user_id "
                + "LEFT JOIN departments d ON u.dept_id = d.dept_id "
                + "WHERE lr.status = 'APPROVED' GROUP BY label ORDER BY label";
        return countMap(sql);
    }

    public Map<String, Integer> monthlyApprovedTrend() throws SQLException {
        String sql = "SELECT DATE_FORMAT(start_date, '%b') label, COUNT(*) total "
                + "FROM leave_requests WHERE status = 'APPROVED' AND YEAR(start_date) = YEAR(CURDATE()) "
                + "GROUP BY MONTH(start_date), DATE_FORMAT(start_date, '%b') ORDER BY MONTH(start_date)";
        return countMap(sql);
    }

    private Map<String, Integer> countMap(String sql) throws SQLException {
        Map<String, Integer> map = new LinkedHashMap<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getString(1), rs.getInt(2));
            }
        }
        return map;
    }
}
