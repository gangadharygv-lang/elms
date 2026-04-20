package com.elms.servlet;

import com.elms.dao.LeaveRequestDAO;
import com.elms.dao.ReportDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet({"/admin/analytics", "/manager/analytics"})
public class AnalyticsServlet extends HttpServlet {
    private final ReportDAO reportDAO = new ReportDAO();
    private final LeaveRequestDAO requestDAO = new LeaveRequestDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        try {
            req.setAttribute("statusStats", reportDAO.countByStatus());
            req.setAttribute("typeStats", reportDAO.countByLeaveType());
            req.setAttribute("departmentStats", reportDAO.countByDepartment());
            req.setAttribute("monthlyStats", reportDAO.monthlyApprovedTrend());
            req.setAttribute("recentRequests", requestDAO.findRecent(10));
            req.getRequestDispatcher("/views/analytics.jsp").forward(req, res);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
