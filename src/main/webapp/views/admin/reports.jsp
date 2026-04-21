<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<h2 class="mb-4">Reports</h2>

<div class="row g-3 mb-4">
    <div class="col-md-4 col-sm-6">
        <div class="card shadow-sm text-center h-100">
            <div class="card-body">
                <h6 class="card-subtitle mb-2 text-muted">Total Leave Requests</h6>
                <h3 class="fw-bold text-success">${leaveCount}</h3>
            </div>
        </div>
    </div>
</div>

<h5 class="mb-3">Recent Requests</h5>
<div class="table-responsive">
    <table class="table table-bordered table-striped align-middle">
        <thead class="table-dark">
            <tr>
                <th>Employee</th>
                <th>Type</th>
                <th>Dates</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="r" items="${recentRequests}">
                <tr>
                    <td>${r.employeeName}</td>
                    <td>${r.leaveTypeCode}</td>
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
