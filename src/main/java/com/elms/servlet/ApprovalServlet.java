package com.elms.servlet;

import com.elms.dao.LeaveRequestDAO;
import com.elms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/manager/approvals")
public class ApprovalServlet extends HttpServlet {
    private final LeaveRequestDAO requestDAO = new LeaveRequestDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        try {
            req.setAttribute("requests", requestDAO.findPendingForManager(user.getUserId()));
            req.getRequestDispatcher("/views/approvalQueue.jsp").forward(req, res);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        String remarks = req.getParameter("remarks");
        if (remarks == null || remarks.trim().isEmpty()) {
            res.sendRedirect(req.getContextPath() + "/manager/approvals?error=remarks-required");
            return;
        }
        try {
            int requestId = Integer.parseInt(req.getParameter("requestId"));
            String action = req.getParameter("action");
            requestDAO.approveOrReject(requestId, user.getUserId(), action, remarks.trim());
            res.sendRedirect(req.getContextPath() + "/manager/approvals?success=updated");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
