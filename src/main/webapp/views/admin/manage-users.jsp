<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<h2 class="mb-4">Manage Users</h2>

<%-- SUCCESS MESSAGES --%>
<c:if test="${param.success == 'created'}">
    <div class="alert alert-success alert-dismissible fade show">
        User created successfully.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
<c:if test="${param.success == 'updated'}">
    <div class="alert alert-success alert-dismissible fade show">
        User updated successfully.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
<c:if test="${param.success == 'status-updated'}">
    <div class="alert alert-success alert-dismissible fade show">
        User status updated.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>

<%-- ADD USER FORM --%>
<div class="card mb-4">
    <div class="card-header fw-semibold">Add New User</div>
    <div class="card-body">
        <%-- FIX: original used col-md-1 for the role dropdown which was too narrow to render
             properly. Changed to col-md-2. Also changed col-md-2 for password to col-md-3. --%>
        <form method="post" action="${pageContext.request.contextPath}/admin/users" class="row g-3">
            <input type="hidden" name="action" value="create"/>
            <div class="col-md-3">
                <input class="form-control" name="employeeCode" placeholder="Employee Code" required>
            </div>
            <div class="col-md-3">
                <input class="form-control" name="fullName" placeholder="Full Name" required>
            </div>
            <div class="col-md-3">
                <input class="form-control" type="email" name="email" placeholder="Email" required>
            </div>
            <div class="col-md-2">
                <input class="form-control" type="password" name="password" placeholder="Password" required>
            </div>
            <%-- FIX: col-md-1 was too narrow for a <select> — bumped to col-md-2 --%>
            <div class="col-md-2">
                <select class="form-select" name="role">
                    <option value="EMP">Employee</option>
                    <option value="MGR">Manager</option>
                    <option value="ADMIN">Admin</option>
                </select>
            </div>
            <div class="col-12">
                <button class="btn btn-success">+ Create User</button>
            </div>
        </form>
    </div>
</div>

<%-- USERS TABLE --%>
<%-- FIX: wrapped in table-responsive to prevent horizontal overflow on smaller screens --%>
<div class="table-responsive">
    <table class="table table-bordered table-striped align-middle">
        <thead class="table-dark">
            <tr>
                <th>ID</th>
                <th>Code</th>
                <th>Name</th>
                <th>Email</th>
                <th>Role</th>
                <th>Status</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="u" items="${users}">
                <tr>
                    <td>${u.userId}</td>
                    <td>${u.employeeCode}</td>
                    <td>${u.fullName}</td>
                    <td>${u.email}</td>
                    <td><span class="badge bg-secondary">${u.role}</span></td>
                    <td>
                        <span class="badge ${u.active ? 'bg-success' : 'bg-danger'}">
                            ${u.active ? 'Active' : 'Inactive'}
                        </span>
                    </td>
                    <td>
                        <form method="post"
                              action="${pageContext.request.contextPath}/admin/users"
                              style="display:inline;">
                            <input type="hidden" name="action" value="toggle"/>
                            <input type="hidden" name="userId" value="${u.userId}"/>
                            <input type="hidden" name="active" value="${u.active ? '0' : '1'}"/>
                            <button class="btn btn-sm ${u.active ? 'btn-warning' : 'btn-outline-success'}">
                                ${u.active ? 'Deactivate' : 'Activate'}
                            </button>
                        </form>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>
