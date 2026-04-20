package com.elms.dao;

import com.elms.model.LeaveRequest;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class LeaveRequestDAO {
    public int submitRequest(LeaveRequest request) throws SQLException {
        String sql = "INSERT INTO leave_requests(user_id, leave_type_id, start_date, end_date, "
                + "duration_days, session, reason, attachment_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, request.getUserId());
            ps.setInt(2, request.getLeaveTypeId());
            ps.setDate(3, Date.valueOf(request.getStartDate()));
            ps.setDate(4, Date.valueOf(request.getEndDate()));
            ps.setBigDecimal(5, request.getDurationDays());
            ps.setString(6, request.getSession().name());
            ps.setString(7, request.getReason());
            ps.setString(8, request.getAttachmentPath());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                return keys.next() ? keys.getInt(1) : 0;
            }
        }
    }

    public boolean hasOverlap(int userId, LocalDate start, LocalDate end) throws SQLException {
        String sql = "SELECT COUNT(*) FROM leave_requests "
                + "WHERE user_id = ? AND status IN ('PENDING','APPROVED') "
                + "AND NOT (end_date < ? OR start_date > ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setDate(2, Date.valueOf(start));
            ps.setDate(3, Date.valueOf(end));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    public List<LeaveRequest> findByUser(int userId) throws SQLException {
        String sql = baseSelect() + " WHERE lr.user_id = ? ORDER BY lr.applied_on DESC";
        List<LeaveRequest> requests = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    requests.add(mapRow(rs));
                }
            }
        }
        return requests;
    }

    public List<LeaveRequest> findPendingForManager(int managerId) throws SQLException {
        String sql = baseSelect()
                + " WHERE u.manager_id = ? AND lr.status = 'PENDING' ORDER BY lr.applied_on ASC";
        List<LeaveRequest> requests = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, managerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    requests.add(mapRow(rs));
                }
            }
        }
        return requests;
    }

    public List<LeaveRequest> findRecent(int limit) throws SQLException {
        String sql = baseSelect() + " ORDER BY lr.applied_on DESC LIMIT ?";
        List<LeaveRequest> requests = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    requests.add(mapRow(rs));
                }
            }
        }
        return requests;
    }

    public void cancelPending(int requestId, int userId) throws SQLException {
        String sql = "UPDATE leave_requests SET status = 'CANCELLED', actioned_on = CURRENT_TIMESTAMP "
                + "WHERE request_id = ? AND user_id = ? AND status = 'PENDING'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    public void approveOrReject(int requestId, int managerId, String action, String remarks) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            LeaveRequest request = findForUpdate(conn, requestId);
            if (request == null || request.getStatus() != LeaveRequest.Status.PENDING) {
                throw new SQLException("Leave request is no longer pending.");
            }

            String status = "approve".equalsIgnoreCase(action) ? "APPROVED" : "REJECTED";
            String update = "UPDATE leave_requests SET status = ?, approved_by = ?, manager_remarks = ?, "
                    + "actioned_on = CURRENT_TIMESTAMP WHERE request_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(update)) {
                ps.setString(1, status);
                ps.setInt(2, managerId);
                ps.setString(3, remarks);
                ps.setInt(4, requestId);
                ps.executeUpdate();
            }

            if ("APPROVED".equals(status)) {
                String balanceSql = "UPDATE leave_balances SET days_taken = days_taken + ?, "
                        + "days_remaining = days_remaining - ? "
                        + "WHERE user_id = ? AND leave_type_id = ? AND year = YEAR(CURDATE()) "
                        + "AND days_remaining >= ?";
                try (PreparedStatement ps = conn.prepareStatement(balanceSql)) {
                    ps.setBigDecimal(1, request.getDurationDays());
                    ps.setBigDecimal(2, request.getDurationDays());
                    ps.setInt(3, request.getUserId());
                    ps.setInt(4, request.getLeaveTypeId());
                    ps.setBigDecimal(5, request.getDurationDays());
                    if (ps.executeUpdate() != 1) {
                        throw new SQLException("Insufficient leave balance at approval time.");
                    }
                }
            }

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback();
            }
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    private LeaveRequest findForUpdate(Connection conn, int requestId) throws SQLException {
        String sql = "SELECT * FROM leave_requests WHERE request_id = ? FOR UPDATE";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                LeaveRequest r = new LeaveRequest();
                r.setRequestId(rs.getInt("request_id"));
                r.setUserId(rs.getInt("user_id"));
                r.setLeaveTypeId(rs.getInt("leave_type_id"));
                r.setDurationDays(rs.getBigDecimal("duration_days"));
                r.setStatus(LeaveRequest.Status.valueOf(rs.getString("status")));
                return r;
            }
        }
    }

    private String baseSelect() {
        return "SELECT lr.*, lt.type_name, lt.type_code, u.full_name AS emp_name, "
                + "u.email AS emp_email, d.dept_name "
                + "FROM leave_requests lr "
                + "JOIN leave_types lt ON lr.leave_type_id = lt.type_id "
                + "JOIN users u ON lr.user_id = u.user_id "
                + "LEFT JOIN departments d ON u.dept_id = d.dept_id";
    }

    private LeaveRequest mapRow(ResultSet rs) throws SQLException {
        LeaveRequest r = new LeaveRequest();
        r.setRequestId(rs.getInt("request_id"));
        r.setUserId(rs.getInt("user_id"));
        r.setLeaveTypeId(rs.getInt("leave_type_id"));
        r.setStartDate(rs.getDate("start_date").toLocalDate());
        r.setEndDate(rs.getDate("end_date").toLocalDate());
        r.setDurationDays(rs.getBigDecimal("duration_days"));
        r.setSession(LeaveRequest.Session.valueOf(rs.getString("session")));
        r.setReason(rs.getString("reason"));
        r.setAttachmentPath(rs.getString("attachment_path"));
        r.setStatus(LeaveRequest.Status.valueOf(rs.getString("status")));
        int approvedBy = rs.getInt("approved_by");
        r.setApprovedBy(rs.wasNull() ? null : approvedBy);
        r.setManagerRemarks(rs.getString("manager_remarks"));
        Timestamp appliedOn = rs.getTimestamp("applied_on");
        r.setAppliedOn(appliedOn == null ? null : appliedOn.toLocalDateTime());
        Timestamp actionedOn = rs.getTimestamp("actioned_on");
        r.setActionedOn(actionedOn == null ? null : actionedOn.toLocalDateTime());
        r.setLeaveTypeName(rs.getString("type_name"));
        r.setLeaveTypeCode(rs.getString("type_code"));
        r.setEmployeeName(rs.getString("emp_name"));
        r.setEmployeeEmail(rs.getString("emp_email"));
        r.setDepartmentName(rs.getString("dept_name"));
        return r;
    }
}
