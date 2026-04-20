package com.elms.dao;

import com.elms.model.LeaveType;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class LeaveTypeDAO {
    public List<LeaveType> findActive() throws SQLException {
        String sql = "SELECT * FROM leave_types WHERE is_active = 1 ORDER BY type_name";
        List<LeaveType> types = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                types.add(mapRow(rs));
            }
        }
        return types;
    }

    public LeaveType findById(int typeId) throws SQLException {
        String sql = "SELECT * FROM leave_types WHERE type_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, typeId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    private LeaveType mapRow(ResultSet rs) throws SQLException {
        LeaveType type = new LeaveType();
        type.setTypeId(rs.getInt("type_id"));
        type.setTypeName(rs.getString("type_name"));
        type.setTypeCode(rs.getString("type_code"));
        type.setMaxDaysPerYear(rs.getInt("max_days_per_year"));
        type.setPaid(rs.getBoolean("is_paid"));
        type.setCarryForwardAllowed(rs.getBoolean("carry_forward_allowed"));
        int maxCarry = rs.getInt("max_carry_forward_days");
        type.setMaxCarryForwardDays(rs.wasNull() ? null : maxCarry);
        type.setRequiresAttachment(rs.getBoolean("requires_attachment"));
        type.setActive(rs.getBoolean("is_active"));
        return type;
    }
}
