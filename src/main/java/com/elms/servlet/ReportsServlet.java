package com.elms.servlet;

import com.elms.dao.LeaveRequestDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/admin/reports")
public class ReportsServlet extends HttpServlet {

    private final LeaveRequestDAO requestDAO = new LeaveRequestDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        try {
            // Basic stats
            req.setAttribute("leaveCount", requestDAO.countAllRequests());
            req.setAttribute("recentRequests", requestDAO.findRecent(10));

            // Layout
            req.setAttribute("pageTitle", "Reports");
            req.setAttribute("contentPage", "/views/admin/reports.jsp");

            req.getRequestDispatcher("/views/common/layout.jsp")
                    .forward(req, res);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}