<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<h2 class="mb-4">Approve Leave Requests</h2>

<c:if test="${param.success == 'updated'}">
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        Request updated successfully.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
<c:if test="${param.error == 'remarks-required'}">
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
        Remarks are required before approving or rejecting.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>

<c:if test="${empty requests}">
    <div class="alert alert-info">No pending leave requests.</div>
</c:if>

<c:if test="${not empty requests}">
    <div class="table-responsive">
        <table class="table table-bordered align-middle">
            <thead class="table-dark">
                <tr>
                    <th>Employee</th>
                    <th>Type</th>
                    <th>Dates</th>
                    <th>Days</th>
                    <th>Reason</th>
                    <th style="min-width:220px">Action</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="r" items="${requests}">
                    <tr>
                        <td>${r.employeeName}</td>
                        <td>${r.leaveTypeCode}</td>
                        <%-- FIX: raw newline between dates caused visible line break in cell --%>
                        <td>${r.startDate} to ${r.endDate}</td>
                        <td>${r.durationDays}</td>
                        <td>${r.reason}</td>
                        <td>
                            <%-- FIX: one single form with two submit buttons.
                                 Original approve-leaves.jsp was already correct here, kept as-is. --%>
                            <form method="post" action="${pageContext.request.contextPath}/manager/approvals">
                                <input type="hidden" name="requestId" value="${r.requestId}">
                                <input class="form-control form-control-sm mb-2"
                                       name="remarks"
                                       placeholder="Enter remarks (required)"
                                       required>
                                <div class="d-flex gap-1">
                                    <button name="action" value="APPROVED"
                                            class="btn btn-success btn-sm flex-fill">â Approve</button>
                                    <button name="action" value="REJECTED"
                                            class="btn btn-danger btn-sm flex-fill">â Reject</button>
                                </div>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</c:if>
