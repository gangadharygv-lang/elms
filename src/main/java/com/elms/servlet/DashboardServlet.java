package com.elms.servlet;

import com.elms.dao.LeaveBalanceDAO;
import com.elms.dao.LeaveRequestDAO;
import com.elms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    private final LeaveBalanceDAO balanceDAO = new LeaveBalanceDAO();
    private final LeaveRequestDAO requestDAO = new LeaveRequestDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        // 🔒 Session check
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login?timeout=true");
            return;
        }

        User user = (User) session.getAttribute("user");
        User.Role role = user.getRole(); // ✅ FIXED

        try {

        	// 👤 EMPLOYEE
        	if (role == User.Role.EMP) {

        	    req.setAttribute("balances",
        	            balanceDAO.findForUser(user.getUserId()));

        	    req.setAttribute("requests",
        	            requestDAO.findByUser(user.getUserId()));

        	    req.setAttribute("pageTitle", "Employee Dashboard");
        	    req.setAttribute("contentPage", "/views/employee/dashboard.jsp");

        	    req.getRequestDispatcher("/views/common/layout.jsp")
        	            .forward(req, res);
        	}

        	else if (role == User.Role.MGR) {

        	    req.setAttribute("pendingRequests",
        	            requestDAO.findPendingForManager(user.getUserId()));

        	    req.setAttribute("pageTitle", "Manager Dashboard");
        	    req.setAttribute("contentPage", "/views/manager/dashboard.jsp");

        	    req.getRequestDispatcher("/views/common/layout.jsp")
        	            .forward(req, res);
        	}

            // 🧑‍💻 ADMIN
            else if (role == User.Role.ADMIN) {

                req.setAttribute("employeeCount",
                        requestDAO.countEmployees());

                req.setAttribute("leaveCount",
                        requestDAO.countAllRequests());

                req.setAttribute("pageTitle", "Admin Dashboard");
                req.setAttribute("contentPage", "/views/admin/dashboard.jsp");

                req.getRequestDispatcher("/views/common/layout.jsp")
                        .forward(req, res);
            }

            // 🚫 Unknown role
            else {
                res.sendRedirect(req.getContextPath() + "/views/error/403.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
            res.sendRedirect(req.getContextPath() + "/views/error/500.jsp");
        }
    }
}