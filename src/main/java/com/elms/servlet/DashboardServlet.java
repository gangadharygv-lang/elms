package com.elms.servlet;

import com.elms.dao.LeaveBalanceDAO;
import com.elms.dao.LeaveRequestDAO;
import com.elms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    private final LeaveBalanceDAO balanceDAO = new LeaveBalanceDAO();
    private final LeaveRequestDAO requestDAO = new LeaveRequestDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        try {
            req.setAttribute("balances", balanceDAO.findForUser(user.getUserId()));
            req.setAttribute("requests", requestDAO.findByUser(user.getUserId()));
            req.getRequestDispatcher("/views/dashboard.jsp").forward(req, res);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
