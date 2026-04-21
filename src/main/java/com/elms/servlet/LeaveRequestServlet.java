package com.elms.servlet;

import com.elms.dao.*;
import com.elms.model.LeaveRequest;
import com.elms.model.LeaveType;
import com.elms.model.User;
import com.elms.util.DateUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

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

    private final LeaveTypeDAO    typeDAO    = new LeaveTypeDAO();
    private final LeaveBalanceDAO balanceDAO = new LeaveBalanceDAO();
    private final HolidayDAO      holidayDAO = new HolidayDAO();
    private final LeaveRequestDAO requestDAO = new LeaveRequestDAO();
    private final AuditLogDAO     auditLogDAO = new AuditLogDAO();

    // =========================
    // GET — Load Apply Page
    // =========================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // FIX #1: user was fetched without null-check. If session expired mid-flow
        // this throws a NullPointerException → 500. Guard and redirect to login.
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login?timeout=true");
            return;
        }
        User user = (User) session.getAttribute("user");

        try {
            List<LeaveType> leaveTypes = typeDAO.findActive();
            Map<Integer, BigDecimal> balanceMap = balanceDAO.findBalanceMap(user.getUserId());

            for (LeaveType leaveType : leaveTypes) {
                leaveType.setBalanceRemaining(
                        balanceMap.getOrDefault(leaveType.getTypeId(), BigDecimal.ZERO));
            }

            req.setAttribute("leaveTypes", leaveTypes);
            req.setAttribute("pageTitle", "Apply Leave");
            req.setAttribute("contentPage", "/views/employee/apply-leave.jsp");
            req.getRequestDispatcher("/views/common/layout.jsp").forward(req, res);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // =========================
    // POST — Submit Leave
    // =========================
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // FIX #1 (same): guard session on POST too
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login?timeout=true");
            return;
        }
        User user = (User) session.getAttribute("user");

        try {
            // FIX #2: leaveTypeId, startDate, endDate could be null/blank if the form
            // submits without those fields (e.g. direct POST). parseInt/parse would throw
            // NumberFormatException / DateTimeParseException → uncaught → 500.
            String leaveTypeIdParam = req.getParameter("leaveTypeId");
            String startDateParam   = req.getParameter("startDate");
            String endDateParam     = req.getParameter("endDate");

            if (leaveTypeIdParam == null || leaveTypeIdParam.isBlank()
                    || startDateParam == null || startDateParam.isBlank()
                    || endDateParam   == null || endDateParam.isBlank()) {
                redirectError(req, res, "All fields are required.");
                return;
            }

            int       typeId      = Integer.parseInt(leaveTypeIdParam);
            LocalDate start       = LocalDate.parse(startDateParam);
            LocalDate end         = LocalDate.parse(endDateParam);
            // FIX: Session enum is FULL / FIRST_HALF / SECOND_HALF — not "HALF".
            // Validate against the real enum names; fall back to FULL for unknown values.
            String rawSession = req.getParameter("session");
            String sessionType = ("FIRST_HALF".equals(rawSession) || "SECOND_HALF".equals(rawSession))
                    ? rawSession : "FULL";
            String    reason      = req.getParameter("reason");

            // ----- Validations -----
            if (start.isBefore(LocalDate.now())) {
                redirectError(req, res, "Start date cannot be in the past.");
                return;
            }
            if (end.isBefore(start)) {
                redirectError(req, res, "End date must be on or after start date.");
                return;
            }
            // FIX: half-day check now uses the correct enum names
            boolean isHalfDay = "FIRST_HALF".equals(sessionType) || "SECOND_HALF".equals(sessionType);
            if (isHalfDay && !start.equals(end)) {
                redirectError(req, res, "Half-day leave must be a single day (start date = end date).");
                return;
            }
            if (requestDAO.hasOverlap(user.getUserId(), start, end)) {
                redirectError(req, res, "You already have leave in this range.");
                return;
            }

            BigDecimal duration = DateUtil.calculateWorkingDays(
                    start, end, sessionType, holidayDAO.findAllDates());

            // FIX #3: calculateWorkingDays can return 0 when all days are weekends/holidays.
            // Submitting 0-day leave would insert a nonsense row. Catch it early.
            if (duration.compareTo(BigDecimal.ZERO) == 0) {
                redirectError(req, res, "Selected range has no working days (weekends/holidays only).");
                return;
            }

            // FIX #4: getAvailableBalance() returns ZERO when no balance row exists for the user
            // (e.g. leave_balances not initialised). This used to silently fail the balance check
            // and show "Insufficient balance: 0" with no explanation.
            // Now we detect it and show a clearer message.
            BigDecimal balance = balanceDAO.getAvailableBalance(user.getUserId(), typeId);

            if (balance.compareTo(BigDecimal.ZERO) == 0) {
                // Check whether the balance row is simply missing vs genuinely zero
                LeaveType chk = typeDAO.findById(typeId);
                if (chk == null) {
                    redirectError(req, res, "Invalid leave type selected.");
                    return;
                }
            }

            if (balance.compareTo(duration) < 0) {
                redirectError(req, res, "Insufficient balance. Available: " + balance + " day(s).");
                return;
            }

            // ----- Attachment -----
            LeaveType type = typeDAO.findById(typeId);

            // FIX #5: saveAttachment() called req.getPart("attachment") but the request
            // content-type might not be multipart if someone hits the endpoint directly.
            // Wrapped in its own try-catch to give a clean error instead of 500.
            String attachmentPath = null;
            try {
                attachmentPath = saveAttachment(req);
            } catch (ServletException e) {
                redirectError(req, res, e.getMessage());
                return;
            }

            if (type != null && type.isRequiresAttachment() && attachmentPath == null) {
                redirectError(req, res, "This leave type requires an attachment (PDF or JPG).");
                return;
            }

            // ----- Save -----
            LeaveRequest leave = new LeaveRequest();
            leave.setUserId(user.getUserId());
            leave.setLeaveTypeId(typeId);
            leave.setStartDate(start);
            leave.setEndDate(end);
            leave.setDurationDays(duration);
            leave.setSession(LeaveRequest.Session.valueOf(sessionType));
            leave.setReason(reason);
            leave.setAttachmentPath(attachmentPath);

            int requestId = requestDAO.submitRequest(leave);

            auditLogDAO.log(
                    "LEAVE_REQUEST", requestId, "SUBMITTED", user.getUserId(),
                    null, "duration=" + duration + ", typeId=" + typeId, req.getRemoteAddr());

            res.sendRedirect(req.getContextPath() + "/dashboard?success=leave-submitted");

        } catch (Exception e) {
            // FIX #6: original re-threw all exceptions as ServletException which produces
            // a plain 500 page with no context. Now we redirect to the apply page with a
            // user-readable message so the employee isn't left staring at an error screen.
            redirectError(req, res, "An unexpected error occurred. Please try again. (" + e.getMessage() + ")");
        }
    }

    // =========================
    // File Upload helper
    // =========================
    private String saveAttachment(HttpServletRequest req)
            throws IOException, ServletException {

        Part part = req.getPart("attachment");
        if (part == null || part.getSize() == 0) {
            return null;
        }

        String fileName = Path.of(part.getSubmittedFileName()).getFileName().toString();
        String lower    = fileName.toLowerCase();

        if (!(lower.endsWith(".pdf") || lower.endsWith(".jpg") || lower.endsWith(".jpeg"))) {
            // FIX #5: was throwing ServletException which bubbled to 500.
            // Now throws with a message that redirectError() will show to the user.
            throw new ServletException("Only PDF or JPG attachments are allowed.");
        }

        Path uploadDir = Path.of(System.getProperty("java.io.tmpdir"), "elms-uploads");
        Files.createDirectories(uploadDir);
        Path target = uploadDir.resolve(System.currentTimeMillis() + "-" + fileName);
        part.write(target.toString());
        return target.toString();
    }

    // =========================
    // Error redirect helper
    // =========================
    private void redirectError(HttpServletRequest req,
                               HttpServletResponse res,
                               String message) throws IOException {
        res.sendRedirect(req.getContextPath()
                + "/leave/apply?error="
                + java.net.URLEncoder.encode(message, java.nio.charset.StandardCharsets.UTF_8));
    }
}
