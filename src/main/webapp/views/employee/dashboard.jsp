<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<h2 class="mb-4">Employee Dashboard</h2>

<h5 class="mb-3">Leave Balance</h5>
<div class="row g-3 mb-4">
    <c:forEach var="b" items="${balances}">
        <div class="col-md-3 col-sm-6">
            <div class="card shadow-sm text-center h-100">
                <div class="card-body">
                    <h6 class="card-subtitle mb-2 text-muted">${b.leaveTypeCode}</h6>
                    <h3 class="fw-bold text-success">${b.daysRemaining}</h3>
                    <small class="text-muted">days remaining</small>
                </div>
            </div>
        </div>
    </c:forEach>
</div>

<h5 class="mb-3">Recent Requests</h5>
<div class="table-responsive">
    <table class="table table-striped table-bordered align-middle">
        <thead class="table-dark">
            <tr>
                <th>Type</th>
                <th>Dates</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="r" items="${requests}">
                <tr>
                    <td>${r.leaveTypeCode}</td>
                    <%-- FIX: original had a raw newline between startDate and endDate
                         which rendered as a line break in the cell --%>
                    <td>${r.startDate} to ${r.endDate}</td>
                    <td>
                        <span class="badge
                            ${r.status == 'APPROVED' ? 'bg-success' :
                              r.status == 'REJECTED' ? 'bg-danger' :
                              'bg-warning text-dark'}">
                            ${r.status}
                        </span>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>

<a href="${pageContext.request.contextPath}/leave/apply"
   class="btn btn-primary mt-3">
   Apply Leave
</a>
