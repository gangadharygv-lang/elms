<%-- FIX: manager/dashboard.jsp was a standalone full HTML page (with its own DOCTYPE,
     head, body, topbar, footer) instead of a content fragment.
     DashboardServlet already wraps it in layout.jsp, so this must be a fragment only. --%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<h2 class="mb-4">Manager Dashboard</h2>

<c:if test="${param.success == 'updated'}">
    <div class="alert alert-success">Request updated successfully.</div>
</c:if>

<h5 class="mb-3">Pending Leave Requests</h5>

<c:if test="${empty pendingRequests}">
    <div class="alert alert-info">No pending requests.</div>
</c:if>

<c:if test="${not empty pendingRequests}">
    <%-- FIX: original used plain <table> with no Bootstrap classes and
         inline-form approve/reject with plain <button>, no Bootstrap styling. --%>
    <div class="table-responsive">
        <table class="table table-bordered table-striped align-middle">
            <thead class="table-dark">
                <tr>
                    <th>Employee</th>
                    <th>Type</th>
                    <th>Dates</th>
                    <th>Days</th>
                    <th>Reason</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="r" items="${pendingRequests}">
                    <tr>
                        <td>${r.employeeName}</td>
                        <td>${r.leaveTypeCode}</td>
                        <td>${r.startDate} to ${r.endDate}</td>
                        <td>${r.durationDays}</td>
                        <td>${r.reason}</td>
                        <td>
                            <%-- FIX: original had TWO separate <form> elements per row (one for
                                 approve, one for reject) each with its own remarks input — the
                                 manager would have to fill remarks twice. Consolidated into one
                                 form with two submit buttons (name="action" value="APPROVED/REJECTED"). --%>
                            <form method="post" action="${pageContext.request.contextPath}/manager/approvals">
                                <input type="hidden" name="requestId" value="${r.requestId}">
                                <input class="form-control form-control-sm mb-2"
                                       name="remarks" placeholder="Remarks" required>
                                <button name="action" value="APPROVED"
                                        class="btn btn-success btn-sm me-1">Approve</button>
                                <button name="action" value="REJECTED"
                                        class="btn btn-danger btn-sm">Reject</button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</c:if>
