<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<h2 class="mb-1">Manager Dashboard</h2>
<p class="text-muted mb-4">Welcome back, <strong>${sessionScope.user.fullName}</strong></p>

<%-- ── ALERTS ───────────────────────────────────────────────── --%>
<c:if test="${param.success == 'updated'}">
    <div class="alert alert-success alert-dismissible fade show">
        Request updated successfully.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>

<%-- ── KPI CARDS ────────────────────────────────────────────── --%>
<div class="row g-3 mb-4">
    <div class="col-6 col-md-3">
        <div class="card text-center border-0 shadow-sm h-100" style="background:#e3f2fd;">
            <div class="card-body py-3">
                <div class="fs-2 fw-bold text-primary">${teamKpi.teamSize}</div>
                <div class="small text-muted">Team Size</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="card text-center border-0 shadow-sm h-100" style="background:#fff8e1;">
            <div class="card-body py-3">
                <div class="fs-2 fw-bold text-warning">${teamKpi.pending}</div>
                <div class="small text-muted">Pending Approvals</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="card text-center border-0 shadow-sm h-100" style="background:#e8f5e9;">
            <div class="card-body py-3">
                <div class="fs-2 fw-bold text-success">${teamKpi.approved}</div>
                <div class="small text-muted">Approved</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="card text-center border-0 shadow-sm h-100" style="background:#f3e5f5;">
            <div class="card-body py-3">
                <div class="fs-2 fw-bold" style="color:#7b1fa2;">${teamKpi.totalDaysTaken}</div>
                <div class="small text-muted">Days Taken</div>
            </div>
        </div>
    </div>
</div>

<%-- ── TABS ─────────────────────────────────────────────────── --%>
<ul class="nav nav-tabs mb-4">
    <li class="nav-item">
        <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#tab-pending">
            &#9203; Pending Approvals
            <c:if test="${not empty pendingRequests}">
                <span class="badge bg-warning text-dark ms-1">${teamKpi.pending}</span>
            </c:if>
        </button>
    </li>
    <li class="nav-item">
        <button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-team">
            &#128101; My Team
        </button>
    </li>
    <li class="nav-item">
        <button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-all">
            &#128203; All Requests
        </button>
    </li>
</ul>

<div class="tab-content">

    <%-- ═══════════ TAB 1 — PENDING APPROVALS ═══════════ --%>
    <div class="tab-pane fade show active" id="tab-pending">
        <c:if test="${empty pendingRequests}">
            <div class="alert alert-info">No pending requests. Your team is all clear.</div>
        </c:if>
        <c:if test="${not empty pendingRequests}">
            <div class="table-responsive">
                <table class="table table-bordered table-striped align-middle">
                    <thead class="table-dark">
                        <tr>
                            <th>Employee</th>
                            <th>Type</th>
                            <th>Dates</th>
                            <th>Days</th>
                            <th>Reason</th>
                            <th style="min-width:210px;">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="r" items="${pendingRequests}">
                            <tr>
                                <td>${r.employeeName}</td>
                                <td><span class="badge bg-secondary">${r.leaveTypeCode}</span></td>
                                <td>${r.startDate} to ${r.endDate}</td>
                                <td class="text-center fw-semibold">${r.durationDays}</td>
                                <td>${r.reason}</td>
                                <td>
                                    <form method="post" action="${pageContext.request.contextPath}/manager/approvals">
                                        <input type="hidden" name="requestId" value="${r.requestId}">
                                        <input class="form-control form-control-sm mb-2"
                                               name="remarks" placeholder="Remarks (required)" required>
                                        <div class="d-flex gap-1">
                                            <button name="action" value="APPROVED"
                                                    class="btn btn-success btn-sm flex-fill">&#10003; Approve</button>
                                            <button name="action" value="REJECTED"
                                                    class="btn btn-danger btn-sm flex-fill">&#10007; Reject</button>
                                        </div>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:if>
    </div>

    <%-- ═══════════ TAB 2 — MY TEAM ═══════════ --%>
    <div class="tab-pane fade" id="tab-team">
        <c:if test="${empty teamMembers}">
            <div class="alert alert-info">No employees are assigned to you yet. Ask the admin to assign employees.</div>
        </c:if>
        <c:if test="${not empty teamMembers}">
            <div class="table-responsive">
                <table class="table table-bordered table-striped align-middle">
                    <thead class="table-dark">
                        <tr>
                            <th>Code</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Department</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="emp" items="${teamMembers}">
                            <tr>
                                <td><code>${emp.employeeCode}</code></td>
                                <td>${emp.fullName}</td>
                                <td>${emp.email}</td>
                                <td>${empty emp.departmentName ? '&#8212;' : emp.departmentName}</td>
                                <td>
                                    <span class="badge ${emp.active ? 'bg-success' : 'bg-danger'}">
                                        ${emp.active ? 'Active' : 'Inactive'}
                                    </span>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:if>
    </div>

    <%-- ═══════════ TAB 3 — ALL REQUESTS ═══════════ --%>
    <div class="tab-pane fade" id="tab-all">
        <c:if test="${empty allRequests}">
            <div class="alert alert-info">No leave requests from your team yet.</div>
        </c:if>
        <c:if test="${not empty allRequests}">
            <div class="table-responsive">
                <table class="table table-bordered table-striped align-middle">
                    <thead class="table-dark">
                        <tr>
                            <th>Employee</th>
                            <th>Type</th>
                            <th>Dates</th>
                            <th>Days</th>
                            <th>Applied On</th>
                            <th>Status</th>
                            <th>Remarks</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="r" items="${allRequests}">
                            <tr>
                                <td>${r.employeeName}</td>
                                <td><span class="badge bg-secondary">${r.leaveTypeCode}</span></td>
                                <td>${r.startDate} to ${r.endDate}</td>
                                <td class="text-center">${r.durationDays}</td>
                                <td>${r.appliedOn}</td>
                                <td>
                                    <span class="badge
                                        ${r.status == 'APPROVED'  ? 'bg-success' :
                                          r.status == 'REJECTED'  ? 'bg-danger'  :
                                          r.status == 'CANCELLED' ? 'bg-secondary' :
                                          'bg-warning text-dark'}">
                                        ${r.status}
                                    </span>
                                </td>
                                <td class="text-muted small">${empty r.managerRemarks ? '&#8212;' : r.managerRemarks}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:if>
    </div>

</div><%-- /tab-content --%>
