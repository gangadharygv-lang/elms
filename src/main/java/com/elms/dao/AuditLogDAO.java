package com.elms.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class AuditLogDAO {
    public void log(String entityType, int entityId, String action, int performedBy,
                    String oldValue, String newValue, String ipAddress) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            log(conn, entityType, entityId, action, performedBy, oldValue, newValue, ipAddress);
        }
    }

    public void log(Connection conn, String entityType, int entityId, String action, int performedBy,
                    String oldValue, String newValue, String ipAddress) throws SQLException {
        String sql = "INSERT INTO audit_log(entity_type, entity_id, action, performed_by, "
                + "old_value, new_value, ip_address) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entityType);
            ps.setInt(2, entityId);
            ps.setString(3, action);
            ps.setInt(4, performedBy);
            ps.setString(5, oldValue);
            ps.setString(6, newValue);
            ps.setString(7, ipAddress);
            ps.executeUpdate();
        }
    }
}
