<%-- This is a content fragment — layout.jsp wraps it. No DOCTYPE/html/head/body here. --%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<h2 class="mb-4">Admin Dashboard</h2>

<div class="row g-3 mb-4">
    <div class="col-md-4 col-sm-6">
        <div class="card shadow-sm text-center h-100">
            <div class="card-body">
                <h6 class="card-subtitle mb-2 text-muted">Total Employees</h6>
                <h3 class="fw-bold text-primary">${employeeCount}</h3>
            </div>
        </div>
    </div>
    <div class="col-md-4 col-sm-6">
        <div class="card shadow-sm text-center h-100">
            <div class="card-body">
                <h6 class="card-subtitle mb-2 text-muted">Total Leave Requests</h6>
                <h3 class="fw-bold text-success">${leaveCount}</h3>
            </div>
        </div>
    </div>
</div>

<div class="d-flex gap-2 flex-wrap">
    <a href="${pageContext.request.contextPath}/admin/users"
       class="btn btn-outline-primary">Manage Users</a>
    <a href="${pageContext.request.contextPath}/admin/reports"
       class="btn btn-outline-secondary">View Reports</a>
</div>
