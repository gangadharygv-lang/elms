package com.elms.servlet;

import com.elms.dao.AuditLogDAO;
import com.elms.dao.LeaveBalanceDAO;
import com.elms.dao.UserDAO;
import com.elms.model.User;
import com.elms.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/admin/users")
public class AdminUsersServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();
    private final LeaveBalanceDAO leaveBalanceDAO = new LeaveBalanceDAO();

    // =========================
    // ✅ LOAD PAGE
    // =========================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        try {
            req.setAttribute("users", userDAO.findAll());
            req.setAttribute("managers", userDAO.findManagers());
            req.setAttribute("departments", userDAO.findAllDepartments());

            req.setAttribute("pageTitle", "Manage Users");
            req.setAttribute("contentPage", "/views/admin/manage-users.jsp");

            req.getRequestDispatcher("/views/common/layout.jsp")
                    .forward(req, res);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // =========================
    // ✅ HANDLE ACTIONS
    // =========================
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        try {
            User admin = (User) req.getSession().getAttribute("user");
            String action = req.getParameter("action");

            if ("create".equals(action)) {
                createUser(req, admin);
                res.sendRedirect(req.getContextPath() + "/admin/users?success=created");

            } else if ("update".equals(action)) {
                updateUser(req, admin);
                res.sendRedirect(req.getContextPath() + "/admin/users?success=updated");

            } else if ("toggle".equals(action)) {
                toggleUser(req, admin);
                res.sendRedirect(req.getContextPath() + "/admin/users?success=status-updated");

            } else if ("changeRole".equals(action)) {
                changeRole(req, admin);
                res.sendRedirect(req.getContextPath() + "/admin/users?success=role-updated");

            } else if ("assignManager".equals(action)) {
                assignManager(req, admin);
                res.sendRedirect(req.getContextPath() + "/admin/users?success=manager-assigned");

            } else {
                res.sendRedirect(req.getContextPath() + "/admin/users");
            }

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // =========================
    // ➕ CREATE USER
    // =========================
    private void createUser(HttpServletRequest req, User admin) throws Exception {

        User user = new User();

        User.Role role = User.Role.valueOf(req.getParameter("role"));
        user.setRole(role);

        // Auto-generate employee code based on role: EMP#####, MGR#####, ADM#####
        String generatedCode = userDAO.generateNextCode(role);
        user.setEmployeeCode(generatedCode);

        user.setFullName(req.getParameter("fullName"));
        user.setEmail(req.getParameter("email"));
        user.setPasswordHash(
                PasswordUtil.sha256(req.getParameter("password"))
        );

        // Department (optional)
        String deptParam = req.getParameter("deptId");
        if (deptParam != null && !deptParam.isBlank()) {
            user.setDeptId(Integer.parseInt(deptParam));
        }

        // Manager assignment — only meaningful for EMP role
        String managerParam = req.getParameter("managerId");
        if (managerParam != null && !managerParam.isBlank()) {
            user.setManagerId(Integer.parseInt(managerParam));
        }

        int userId = userDAO.create(user);

        // Initialize leave balance
        leaveBalanceDAO.initializeDefaultBalances(userId);

        auditLogDAO.log(
                "USER",
                userId,
                "CREATED",
                admin.getUserId(),
                null,
                user.getEmail() + " | role=" + user.getRole(),
                req.getRemoteAddr()
        );
    }

    // =========================
    // ✏️ UPDATE USER
    // =========================
    private void updateUser(HttpServletRequest req, User admin) throws Exception {

        User user = new User();

        user.setUserId(Integer.parseInt(req.getParameter("userId")));
        user.setEmployeeCode(req.getParameter("employeeCode"));
        user.setFullName(req.getParameter("fullName"));
        user.setEmail(req.getParameter("email"));
        user.setRole(User.Role.valueOf(req.getParameter("role")));
        user.setActive("1".equals(req.getParameter("active")));

        userDAO.updateBasic(user);

        String password = req.getParameter("password");
        if (password != null && !password.isBlank()) {
            userDAO.updatePassword(
                    user.getUserId(),
                    PasswordUtil.sha256(password)
            );
        }

        auditLogDAO.log(
                "USER",
                user.getUserId(),
                "UPDATED",
                admin.getUserId(),
                null,
                user.getEmail()
                        + " | role=" + user.getRole()
                        + " | active=" + user.isActive(),
                req.getRemoteAddr()
        );
    }

    // =========================
    // 🔄 TOGGLE ACTIVE/INACTIVE
    // =========================
    private void toggleUser(HttpServletRequest req, User admin) throws Exception {

        int userId = Integer.parseInt(req.getParameter("userId"));
        boolean active = "1".equals(req.getParameter("active"));

        // Prevent self-deactivation
        if (userId == admin.getUserId() && !active) {
            throw new ServletException("You cannot deactivate your own account.");
        }

        userDAO.setActive(userId, active);

        auditLogDAO.log(
                "USER",
                userId,
                active ? "ACTIVATED" : "DEACTIVATED",
                admin.getUserId(),
                null,
                "active=" + active,
                req.getRemoteAddr()
        );
    }

    // =========================
    // 🔄 CHANGE ROLE
    // =========================
    private void changeRole(HttpServletRequest req, User admin) throws Exception {

        int userId = Integer.parseInt(req.getParameter("userId"));

        // Prevent admin from changing their own role
        if (userId == admin.getUserId()) {
            throw new ServletException("You cannot change your own role.");
        }

        User.Role newRole = User.Role.valueOf(req.getParameter("newRole"));

        // Only re-generate the employee code when the role prefix actually changes
        User existing = userDAO.findById(userId);
        String newCode = existing.getEmployeeCode();

        String currentPrefix = newCode != null && newCode.length() >= 3
                ? newCode.substring(0, 3) : "";
        String expectedPrefix;
        if (newRole == User.Role.MGR) {
            expectedPrefix = "MGR";
        } else if (newRole == User.Role.ADMIN) {
            expectedPrefix = "ADM";
        } else {
            expectedPrefix = "EMP";
        }

        if (!currentPrefix.equals(expectedPrefix)) {
            newCode = userDAO.generateNextCode(newRole);
        }

        userDAO.updateRole(userId, newRole, newCode);

        auditLogDAO.log(
                "USER",
                userId,
                "ROLE_CHANGED",
                admin.getUserId(),
                "role=" + existing.getRole() + " | code=" + existing.getEmployeeCode(),
                "role=" + newRole + " | code=" + newCode,
                req.getRemoteAddr()
        );
    }

    // =========================
    // 👤 ASSIGN MANAGER
    // =========================
    private void assignManager(HttpServletRequest req, User admin) throws Exception {

        int userId = Integer.parseInt(req.getParameter("userId"));
        String managerParam = req.getParameter("managerId");

        Integer managerId = (managerParam != null && !managerParam.isBlank())
                ? Integer.parseInt(managerParam) : null;

        User existing = userDAO.findById(userId);

        userDAO.assignManager(userId, managerId);

        auditLogDAO.log(
                "USER",
                userId,
                "MANAGER_ASSIGNED",
                admin.getUserId(),
                "managerId=" + existing.getManagerId(),
                "managerId=" + managerId,
                req.getRemoteAddr()
        );
    }
}