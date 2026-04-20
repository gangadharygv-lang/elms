package com.elms.servlet;

import com.elms.dao.LeaveRequestDAO;
import com.elms.dao.ReportDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Map;

@WebServlet({"/admin/analytics", "/manager/analytics"})
public class AnalyticsServlet extends HttpServlet {
    private final ReportDAO reportDAO = new ReportDAO();
    private final LeaveRequestDAO requestDAO = new LeaveRequestDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        try {
            Map<String, Integer> statusStats = reportDAO.countByStatus();
            Map<String, Integer> typeStats = reportDAO.countByLeaveType();
            Map<String, Integer> departmentStats = reportDAO.countByDepartment();
            Map<String, Integer> monthlyStats = reportDAO.monthlyApprovedTrend();
            req.setAttribute("statusStats", statusStats);
            req.setAttribute("typeStats", typeStats);
            req.setAttribute("departmentStats", departmentStats);
            req.setAttribute("monthlyStats", monthlyStats);
            req.setAttribute("statusLabelsJson", labelsJson(statusStats));
            req.setAttribute("statusDataJson", dataJson(statusStats));
            req.setAttribute("typeLabelsJson", labelsJson(typeStats));
            req.setAttribute("typeDataJson", dataJson(typeStats));
            req.setAttribute("departmentLabelsJson", labelsJson(departmentStats));
            req.setAttribute("departmentDataJson", dataJson(departmentStats));
            req.setAttribute("monthlyLabelsJson", labelsJson(monthlyStats));
            req.setAttribute("monthlyDataJson", dataJson(monthlyStats));
            req.setAttribute("recentRequests", requestDAO.findRecent(10));
            req.getRequestDispatcher("/views/analytics.jsp").forward(req, res);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private String labelsJson(Map<String, Integer> map) {
        StringBuilder json = new StringBuilder("[");
        boolean first = true;
        for (String key : map.keySet()) {
            if (!first) {
                json.append(',');
            }
            json.append('"').append(escapeJson(key)).append('"');
            first = false;
        }
        return json.append(']').toString();
    }

    private String dataJson(Map<String, Integer> map) {
        StringBuilder json = new StringBuilder("[");
        boolean first = true;
        for (Integer value : map.values()) {
            if (!first) {
                json.append(',');
            }
            json.append(value == null ? 0 : value);
            first = false;
        }
        return json.append(']').toString();
    }

    private String escapeJson(String input) {
        if (input == null) {
            return "";
        }
        return input.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
