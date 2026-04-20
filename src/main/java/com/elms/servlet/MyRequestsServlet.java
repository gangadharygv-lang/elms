package com.elms.servlet;

import com.elms.dao.LeaveRequestDAO;
import com.elms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/leave/my-requests")
public class MyRequestsServlet extends HttpServlet {
    private final LeaveRequestDAO requestDAO = new LeaveRequestDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        try {
            req.setAttribute("requests", requestDAO.findByUser(user.getUserId()));
            req.getRequestDispatcher("/views/myRequests.jsp").forward(req, res);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        try {
            int requestId = Integer.parseInt(req.getParameter("requestId"));
            requestDAO.cancelPending(requestId, user.getUserId());
            res.sendRedirect(req.getContextPath() + "/leave/my-requests?success=cancelled");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
