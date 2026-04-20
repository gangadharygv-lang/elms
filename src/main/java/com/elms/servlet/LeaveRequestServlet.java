package com.elms.servlet;

import com.elms.dao.HolidayDAO;
import com.elms.dao.LeaveBalanceDAO;
import com.elms.dao.LeaveRequestDAO;
import com.elms.dao.LeaveTypeDAO;
import com.elms.model.LeaveRequest;
import com.elms.model.LeaveType;
import com.elms.model.User;
import com.elms.util.DateUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@WebServlet("/leave/apply")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024)
public class LeaveRequestServlet extends HttpServlet {
    private final LeaveTypeDAO typeDAO = new LeaveTypeDAO();
    private final LeaveBalanceDAO balanceDAO = new LeaveBalanceDAO();
    private final HolidayDAO holidayDAO = new HolidayDAO();
    private final LeaveRequestDAO requestDAO = new LeaveRequestDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        try {
            List<LeaveType> leaveTypes = typeDAO.findActive();
            Map<Integer, BigDecimal> balanceMap = balanceDAO.findBalanceMap(user.getUserId());
            for (LeaveType leaveType : leaveTypes) {
                leaveType.setBalanceRemaining(
                        balanceMap.getOrDefault(leaveType.getTypeId(), BigDecimal.ZERO));
            }
            req.setAttribute("leaveTypes", leaveTypes);
            req.getRequestDispatcher("/views/applyLeave.jsp").forward(req, res);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        try {
            int typeId = Integer.parseInt(req.getParameter("leaveTypeId"));
            LocalDate start = LocalDate.parse(req.getParameter("startDate"));
            LocalDate end = LocalDate.parse(req.getParameter("endDate"));
            String session = req.getParameter("session") == null ? "FULL" : req.getParameter("session");
            String reason = req.getParameter("reason");

            if (start.isBefore(LocalDate.now())) {
                redirectError(req, res, "Start date cannot be in the past.");
                return;
            }
            if (end.isBefore(start)) {
                redirectError(req, res, "End date must be on or after start date.");
                return;
            }
            if (!"FULL".equals(session) && !start.equals(end)) {
                redirectError(req, res, "Half-day leave must start and end on the same date.");
                return;
            }
            if (requestDAO.hasOverlap(user.getUserId(), start, end)) {
                redirectError(req, res, "You already have leave in this date range.");
                return;
            }

            BigDecimal duration = DateUtil.calculateWorkingDays(start, end, session, holidayDAO.findAllDates());
            BigDecimal balance = balanceDAO.getAvailableBalance(user.getUserId(), typeId);
            if (balance.compareTo(duration) < 0) {
                redirectError(req, res, "Insufficient balance. Available: " + balance + " day(s).");
                return;
            }

            LeaveType type = typeDAO.findById(typeId);
            String attachmentPath = saveAttachment(req, type);
            if (type != null && type.isRequiresAttachment() && attachmentPath == null) {
                redirectError(req, res, "This leave type requires a PDF or JPG document.");
                return;
            }

            LeaveRequest leave = new LeaveRequest();
            leave.setUserId(user.getUserId());
            leave.setLeaveTypeId(typeId);
            leave.setStartDate(start);
            leave.setEndDate(end);
            leave.setDurationDays(duration);
            leave.setSession(LeaveRequest.Session.valueOf(session));
            leave.setReason(reason);
            leave.setAttachmentPath(attachmentPath);
            requestDAO.submitRequest(leave);
            res.sendRedirect(req.getContextPath() + "/dashboard?success=leave-submitted");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private String saveAttachment(HttpServletRequest req, LeaveType type) throws IOException, ServletException {
        Part part = req.getPart("attachment");
        if (part == null || part.getSize() == 0) {
            return null;
        }
        String submitted = Path.of(part.getSubmittedFileName()).getFileName().toString();
        String lower = submitted.toLowerCase();
        if (!(lower.endsWith(".pdf") || lower.endsWith(".jpg") || lower.endsWith(".jpeg"))) {
            throw new ServletException("Only PDF and JPG uploads are allowed.");
        }
        Path uploadDir = Path.of(System.getProperty("java.io.tmpdir"), "elms-uploads");
        Files.createDirectories(uploadDir);
        Path target = uploadDir.resolve(System.currentTimeMillis() + "-" + submitted);
        part.write(target.toString());
        return target.toString();
    }

    private void redirectError(HttpServletRequest req, HttpServletResponse res, String message) throws IOException {
        res.sendRedirect(req.getContextPath() + "/leave/apply?error="
                + java.net.URLEncoder.encode(message, java.nio.charset.StandardCharsets.UTF_8));
    }
}
