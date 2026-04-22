package com.elms.servlet;

import com.elms.dao.ReportDAO;
import com.elms.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * Serves analytics for two roles:
 *   GET /admin/analytics   — full org-wide analytics (ADMIN only, guarded by AuthFilter)
 *   GET /manager/analytics — team-scoped analytics   (MGR,   guarded by AuthFilter)
 */
@WebServlet({"/admin/analytics", "/manager/analytics"})
public class AnalyticsServlet extends HttpServlet {

    private final ReportDAO reportDAO = new ReportDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        String path = req.getServletPath();

        try {
            if ("/admin/analytics".equals(path)) {
                loadAdminAnalytics(req);
                req.setAttribute("pageTitle", "Analytics");
                req.setAttribute("contentPage", "/views/admin/analytics.jsp");
            } else {
                loadManagerAnalytics(req, user.getUserId());
                req.setAttribute("pageTitle", "Team Analytics");
                req.setAttribute("contentPage", "/views/manager/analytics.jsp");
            }
            req.getRequestDispatcher("/views/common/layout.jsp").forward(req, res);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ── Admin: full org data ──────────────────────────────────────
    private void loadAdminAnalytics(HttpServletRequest req) throws Exception {

        Map<String, Integer> kpi        = reportDAO.kpiSummary();
        Map<String, Integer> statusMap  = reportDAO.countByStatus();
        Map<String, Integer> typeMap    = reportDAO.countByLeaveType();
        Map<String, Integer> monthMap   = reportDAO.monthlyApprovedTrend();
        Map<String, Integer> deptMap    = reportDAO.approvedDaysByDepartment();

        List<Object[]> topConsumers     = reportDAO.topLeaveConsumers(10);
        List<Object[]> empSummary       = reportDAO.employeeLeaveSummary();
        List<Object[]> typeBalance      = reportDAO.leaveTypeBalanceSummary();

        req.setAttribute("kpi",          kpi);
        req.setAttribute("statusMap",    statusMap);
        req.setAttribute("typeMap",      typeMap);
        req.setAttribute("monthMap",     monthMap);
        req.setAttribute("deptMap",      deptMap);
        req.setAttribute("topConsumers", topConsumers);
        req.setAttribute("empSummary",   empSummary);
        req.setAttribute("typeBalance",  typeBalance);

        // JSON for Chart.js
        req.setAttribute("statusLabelsJson", labelsJson(statusMap));
        req.setAttribute("statusDataJson",   dataJson(statusMap));
        req.setAttribute("typeLabelsJson",   labelsJson(typeMap));
        req.setAttribute("typeDataJson",     dataJson(typeMap));
        req.setAttribute("monthLabelsJson",  labelsJson(monthMap));
        req.setAttribute("monthDataJson",    dataJson(monthMap));
        req.setAttribute("deptLabelsJson",   labelsJson(deptMap));
        req.setAttribute("deptDataJson",     dataJson(deptMap));
    }

    // ── Manager: team-scoped data ─────────────────────────────────
    private void loadManagerAnalytics(HttpServletRequest req, int managerId) throws Exception {

        Map<String, Integer> kpi       = reportDAO.kpiSummaryForManager(managerId);
        Map<String, Integer> statusMap = reportDAO.countByStatusForManager(managerId);
        Map<String, Integer> monthMap  = reportDAO.monthlyTrendForManager(managerId);
        Map<String, Integer> typeMap   = reportDAO.leaveTypeForManager(managerId);
        List<Object[]> teamSummary     = reportDAO.teamLeaveSummary(managerId);

        req.setAttribute("kpi",         kpi);
        req.setAttribute("statusMap",   statusMap);
        req.setAttribute("monthMap",    monthMap);
        req.setAttribute("typeMap",     typeMap);
        req.setAttribute("teamSummary", teamSummary);

        req.setAttribute("statusLabelsJson", labelsJson(statusMap));
        req.setAttribute("statusDataJson",   dataJson(statusMap));
        req.setAttribute("typeLabelsJson",   labelsJson(typeMap));
        req.setAttribute("typeDataJson",     dataJson(typeMap));
        req.setAttribute("monthLabelsJson",  labelsJson(monthMap));
        req.setAttribute("monthDataJson",    dataJson(monthMap));
    }

    // ── JSON helpers ──────────────────────────────────────────────
    private String labelsJson(Map<String, Integer> map) {
        StringBuilder sb = new StringBuilder("[");
        boolean first = true;
        for (String k : map.keySet()) {
            if (!first) sb.append(',');
            // Escape quotes just in case a dept name contains one
            sb.append('"').append(k.replace("\"", "\\\"")).append('"');
            first = false;
        }
        return sb.append(']').toString();
    }

    private String dataJson(Map<String, Integer> map) {
        StringBuilder sb = new StringBuilder("[");
        boolean first = true;
        for (Integer v : map.values()) {
            if (!first) sb.append(',');
            sb.append(v == null ? 0 : v);
            first = false;
        }
        return sb.append(']').toString();
    }
}
