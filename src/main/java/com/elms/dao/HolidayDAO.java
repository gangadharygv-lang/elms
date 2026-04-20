package com.elms.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.LinkedHashSet;
import java.util.Set;

public class HolidayDAO {
    public Set<LocalDate> findAllDates() throws SQLException {
        String sql = "SELECT holiday_date FROM public_holidays";
        Set<LocalDate> dates = new LinkedHashSet<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                dates.add(rs.getDate("holiday_date").toLocalDate());
            }
        }
        return dates;
    }
}
