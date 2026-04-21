package com.elms.dao;

import com.elms.model.LeaveBalance;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Year;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class LeaveBalanceDAO {
    public BigDecimal getAvailableBalance(int userId, int leaveTypeId) throws SQLException {
        String sql = "SELECT days_remaining FROM leave_balances "
                + "WHERE user_id = ? AND leave_type_id = ? AND year = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, leaveTypeId);
            ps.setInt(3, Year.now().getValue());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal("days_remaining") : BigDecimal.ZERO;
            }
        }
    }

    public List<LeaveBalance> findForUser(int userId) throws SQLException {
        String sql = "SELECT lb.*, lt.type_name, lt.type_code FROM leave_balances lb "
                + "JOIN leave_types lt ON lb.leave_type_id = lt.type_id "
                + "WHERE lb.user_id = ? AND lb.year = ? ORDER BY lt.type_name";
        List<LeaveBalance> balances = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, Year.now().getValue());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    balances.add(mapRow(rs));
                }
            }
        }
        return balances;
    }

    public Map<Integer, BigDecimal> findBalanceMap(int userId) throws SQLException {
        Map<Integer, BigDecimal> map = new LinkedHashMap<>();
        for (LeaveBalance balance : findForUser(userId)) {
            map.put(balance.getLeaveTypeId(), balance.getDaysRemaining());
        }
        return map;
    }

    private LeaveBalance mapRow(ResultSet rs) throws SQLException {
        LeaveBalance balance = new LeaveBalance();
        balance.setBalanceId(rs.getInt("balance_id"));
        balance.setUserId(rs.getInt("user_id"));
        balance.setLeaveTypeId(rs.getInt("leave_type_id"));
        balance.setYear(rs.getInt("year"));
        balance.setTotalEntitled(rs.getInt("total_entitled"));
        balance.setDaysTaken(rs.getBigDecimal("days_taken"));
        balance.setDaysRemaining(rs.getBigDecimal("days_remaining"));
        balance.setCarriedForward(rs.getBigDecimal("carried_forward"));
        balance.setLeaveTypeName(rs.getString("type_name"));
        balance.setLeaveTypeCode(rs.getString("type_code"));
        return balance;
    }
    public void initializeDefaultBalances(int userId) throws SQLException {
        String leaveTypeSql = "SELECT type_id, max_days_per_year FROM leave_types WHERE is_active = TRUE";
        String insertSql = "INSERT INTO leave_balances (user_id, leave_type_id, year, total_entitled, days_remaining) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ltStmt = conn.prepareStatement(leaveTypeSql);
             ResultSet rs = ltStmt.executeQuery()) {

            while (rs.next()) {
                int leaveTypeId = rs.getInt("type_id");
                int maxDays = rs.getInt("max_days_per_year");

                try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                    insertStmt.setInt(1, userId);
                    insertStmt.setInt(2, leaveTypeId);
                    insertStmt.setInt(3, java.time.Year.now().getValue());
                    insertStmt.setInt(4, maxDays);
                    insertStmt.setBigDecimal(5, new java.math.BigDecimal(maxDays));
                    insertStmt.executeUpdate();
                }
            }
        }
    }
}
