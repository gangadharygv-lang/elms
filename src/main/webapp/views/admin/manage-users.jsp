<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<h2 class="mb-4">Manage Users</h2>

<%-- ── FLASH ALERTS ─────────────────────────────────────────────── --%>
<c:if test="${param.success == 'created'}">
    <div class="alert alert-success alert-dismissible fade show">
        User created successfully.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
<c:if test="${param.success == 'role-updated'}">
    <div class="alert alert-success alert-dismissible fade show">
        Role updated successfully.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
<c:if test="${param.success == 'manager-assigned'}">
    <div class="alert alert-success alert-dismissible fade show">
        Manager assigned successfully.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
<c:if test="${param.success == 'status-updated'}">
    <div class="alert alert-success alert-dismissible fade show">
        User status updated.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
<c:if test="${param.success == 'updated'}">
    <div class="alert alert-success alert-dismissible fade show">
        User updated successfully.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>

<%-- ── TAB NAV ──────────────────────────────────────────────────── --%>
<ul class="nav nav-tabs mb-4" id="userTabs">
    <li class="nav-item">
        <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#tab-show">
            &#128101; Show Employees
        </button>
    </li>
    <li class="nav-item">
        <button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-edit" id="editTabBtn">
            &#9998; Edit Employee
        </button>
    </li>
    <li class="nav-item">
        <button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-create">
            &#43; Create Employee
        </button>
    </li>
</ul>

<div class="tab-content">

    <%-- ═══════════════ TAB 1 — SHOW EMPLOYEES ═══════════════ --%>
    <div class="tab-pane fade show active" id="tab-show">

        <%-- ── FILTER BAR ── --%>
        <div class="card mb-3 border-0 bg-light">
            <div class="card-body py-2">
                <div class="row g-2 align-items-end">
                    <div class="col-md-3">
                        <label class="form-label small fw-semibold mb-1">&#128269; Search</label>
                        <input type="text" id="filterSearch" class="form-control form-control-sm"
                               placeholder="Name, email or code..." oninput="applyFilters()">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label small fw-semibold mb-1">Role</label>
                        <select id="filterRole" class="form-select form-select-sm" onchange="applyFilters()">
                            <option value="">All Roles</option>
                            <option value="EMP">Employee</option>
                            <option value="MGR">Manager</option>
                            <option value="ADMIN">Admin</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label small fw-semibold mb-1">Department</label>
                        <select id="filterDept" class="form-select form-select-sm" onchange="applyFilters()">
                            <option value="">All Departments</option>
                            <c:forEach var="dept" items="${departments}">
                                <option value="${dept.value}">${dept.value}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label small fw-semibold mb-1">Status</label>
                        <select id="filterStatus" class="form-select form-select-sm" onchange="applyFilters()">
                            <option value="">All Status</option>
                            <option value="active">Active</option>
                            <option value="inactive">Inactive</option>
                        </select>
                    </div>
                    <div class="col-md-2 d-flex align-items-end">
                        <button class="btn btn-sm btn-outline-secondary w-100" onclick="clearFilters()">&#10005; Clear Filters</button>
                    </div>
                </div>
                <div class="mt-2 text-muted small" id="filterCount"></div>
            </div>
        </div>

        <div class="table-responsive">
            <table class="table table-bordered table-striped align-middle">
                <thead class="table-dark">
                    <tr>
                        <th>Code</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Department</th>
                        <th>Status</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody id="employeeTableBody">
                    <c:forEach var="u" items="${users}">
                        <c:set var="rowStatus" value="inactive"/>
                        <c:if test="${u.active}"><c:set var="rowStatus" value="active"/></c:if>
                        <c:set var="rowDept" value="${empty u.departmentName ? '' : u.departmentName}"/>
                        <c:choose>
                            <c:when test="${not u.active}">
                                <tr data-role="${u.role}"
                                    data-dept="${rowDept}"
                                    data-status="${rowStatus}"
                                    data-search="${u.fullName} ${u.email} ${u.employeeCode}"
                                    style="opacity:0.5; background:#f8f8f8;">
                            </c:when>
                            <c:otherwise>
                                <tr data-role="${u.role}"
                                    data-dept="${rowDept}"
                                    data-status="${rowStatus}"
                                    data-search="${u.fullName} ${u.email} ${u.employeeCode}">
                            </c:otherwise>
                        </c:choose>
                            <td>
                                <code style="${not u.active ? 'text-decoration:line-through;' : ''}">${u.employeeCode}</code>
                            </td>
                            <td style="${not u.active ? 'text-decoration:line-through; color:#999;' : ''}">${u.fullName}</td>
                            <td style="${not u.active ? 'color:#aaa;' : ''}">${u.email}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${u.role == 'EMP'}">
                                        <span class="badge bg-primary">Employee</span>
                                    </c:when>
                                    <c:when test="${u.role == 'MGR'}">
                                        <span class="badge bg-info text-dark">Manager</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-dark">Admin</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td style="${not u.active ? 'color:#aaa;' : ''}">${empty u.departmentName ? '&mdash;' : u.departmentName}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${u.active}">
                                        <span class="badge bg-success">Active</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary">Dormant</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <button class="btn btn-sm btn-outline-secondary"
                                        onclick="openEditTab('${u.userId}')">
                                    Edit
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <%-- ═══════════════ TAB 2 — EDIT EMPLOYEE ═══════════════ --%>
    <div class="tab-pane fade" id="tab-edit">

        <div class="mb-4">
            <label class="form-label fw-semibold">Select Employee</label>
            <select class="form-select w-auto" id="editUserSelect" onchange="loadEditCards()">
                <option value="">-- Choose an employee --</option>
                <c:forEach var="u" items="${users}">
                    <option value="${u.userId}"
                            data-name="${u.fullName}"
                            data-role="${u.role}"
                            data-manager="${u.managerId}"
                            data-active="${u.active}"
                            data-self="${sessionScope.user.userId == u.userId}">
                        ${u.fullName} (${u.employeeCode})
                    </option>
                </c:forEach>
            </select>
        </div>

        <div id="editCards" style="display:none;">
            <div class="row g-3">

                <%-- Change Role --%>
                <div class="col-md-4" id="cardRole">
                    <div class="card h-100 border-primary">
                        <div class="card-header fw-semibold bg-primary text-white">
                            Change Role
                        </div>
                        <div class="card-body">
                            <p class="card-text text-muted small">
                                Changing role also reassigns the employee code prefix
                                (EMP / MGR / ADM).
                            </p>
                            <form method="post"
                                  action="${pageContext.request.contextPath}/admin/users">
                                <input type="hidden" name="action" value="changeRole"/>
                                <input type="hidden" name="userId" id="roleUserId"/>
                                <div class="mb-3">
                                    <label class="form-label">New Role</label>
                                    <select class="form-select" name="newRole" id="editRoleSelect">
                                        <option value="EMP">Employee</option>
                                        <option value="MGR">Manager</option>
                                        <option value="ADMIN">Admin</option>
                                    </select>
                                </div>
                                <button class="btn btn-primary w-100">Save Role</button>
                            </form>
                        </div>
                    </div>
                </div>

                <%-- Assign Manager --%>
                <div class="col-md-4" id="cardManager">
                    <div class="card h-100 border-info">
                        <div class="card-header fw-semibold bg-info text-dark">
                            Assign Manager
                        </div>
                        <div class="card-body">
                            <p class="card-text text-muted small">
                                The assigned manager sees this employee's leave
                                requests in their portal.
                            </p>
                            <form method="post"
                                  action="${pageContext.request.contextPath}/admin/users">
                                <input type="hidden" name="action" value="assignManager"/>
                                <input type="hidden" name="userId" id="managerUserId"/>
                                <div class="mb-3">
                                    <label class="form-label">Manager</label>
                                    <select class="form-select" name="managerId" id="managerSelect">
                                        <option value="">-- None --</option>
                                        <c:forEach var="mgr" items="${managers}">
                                            <option value="${mgr.userId}">${mgr.fullName}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <button class="btn btn-info w-100 text-dark">Save Manager</button>
                            </form>
                        </div>
                    </div>
                </div>

                <%-- Account Status --%>
                <div class="col-md-4" id="cardStatus">
                    <div class="card h-100 border-warning">
                        <div class="card-header fw-semibold bg-warning text-dark">
                            Account Status
                        </div>
                        <div class="card-body d-flex flex-column">
                            <p class="card-text text-muted small">
                                Deactivated accounts cannot log in. You cannot
                                deactivate your own account.
                            </p>
                            <p class="mb-3">
                                Current status: <span id="statusBadge" class="badge"></span>
                            </p>
                            <form method="post"
                                  action="${pageContext.request.contextPath}/admin/users"
                                  class="mt-auto">
                                <input type="hidden" name="action" value="toggle"/>
                                <input type="hidden" name="userId" id="toggleUserId"/>
                                <input type="hidden" name="active" id="toggleActiveVal"/>
                                <button class="btn w-100" id="toggleBtn">Toggle</button>
                            </form>
                        </div>
                    </div>
                </div>

            </div>

            <div id="selfWarning" class="alert alert-warning mt-3" style="display:none;">
                You are editing your own account. Role and status changes are disabled.
            </div>
        </div>
    </div>

    <%-- ═══════════════ TAB 3 — CREATE EMPLOYEE ═══════════════ --%>
    <div class="tab-pane fade" id="tab-create">
        <div class="card">
            <div class="card-header fw-semibold">New Employee Details</div>
            <div class="card-body">
                <p class="text-muted small mb-3">
                    Employee ID is assigned automatically based on role
                    (e.g. <code>EMP00001</code>, <code>MGR00001</code>, <code>ADM00001</code>).
                </p>
                <form method="post"
                      action="${pageContext.request.contextPath}/admin/users"
                      class="row g-3">
                    <input type="hidden" name="action" value="create"/>

                    <div class="col-md-6">
                        <label class="form-label">Full Name</label>
                        <input class="form-control" name="fullName"
                               placeholder="e.g. Priya Sharma" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Email</label>
                        <input class="form-control" type="email" name="email"
                               placeholder="e.g. priya@company.com" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Password</label>
                        <input class="form-control" type="password" name="password"
                               placeholder="Temporary password" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Role</label>
                        <select class="form-select" name="role" id="createRoleSelect"
                                onchange="updateCreateUI()">
                            <option value="EMP">Employee</option>
                            <option value="MGR">Manager</option>
                            <option value="ADMIN">Admin</option>
                        </select>
                        <div class="form-text">
                            Auto ID: <strong id="createCodePreview">EMP#####</strong>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Department</label>
                        <select class="form-select" name="deptId">
                            <option value="">-- None --</option>
                            <c:forEach var="dept" items="${departments}">
                                <option value="${dept.key}">${dept.value}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-4" id="createManagerField">
                        <label class="form-label">
                            Assign Manager <span class="text-danger">*</span>
                        </label>
                        <select class="form-select" name="managerId">
                            <option value="">-- None --</option>
                            <c:forEach var="mgr" items="${managers}">
                                <option value="${mgr.userId}">${mgr.fullName}</option>
                            </c:forEach>
                        </select>
                        <div class="form-text text-danger">
                            Required for employees — leave requests won't appear in
                            the manager portal otherwise.
                        </div>
                    </div>

                    <div class="col-12 mt-2">
                        <button class="btn btn-success px-4">Create User</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

</div><%-- /tab-content --%>

<script>
(function () {

    /* ── Create tab ── */
    function updateCreateUI() {
        var role = document.getElementById('createRoleSelect').value;
        var map  = { EMP: 'EMP#####', MGR: 'MGR#####', ADM: 'ADM#####' };
        document.getElementById('createCodePreview').textContent = map[role] || '';
        document.getElementById('createManagerField').style.display =
            role === 'EMP' ? '' : 'none';
    }
    window.updateCreateUI = updateCreateUI;
    updateCreateUI();

    /* ── Edit tab: populate cards ── */
    function loadEditCards() {
        var sel = document.getElementById('editUserSelect');
        var opt = sel.options[sel.selectedIndex];
        if (!opt || !opt.value) {
            document.getElementById('editCards').style.display = 'none';
            return;
        }

        var userId  = opt.value;
        var role    = opt.dataset.role;
        var manager = opt.dataset.manager;
        var active  = opt.dataset.active === 'true';
        var isSelf  = opt.dataset.self === 'true';

        document.getElementById('editCards').style.display = '';

        /* Role card */
        document.getElementById('roleUserId').value = userId;
        var rs = document.getElementById('editRoleSelect');
        for (var i = 0; i < rs.options.length; i++) {
            rs.options[i].selected = (rs.options[i].value === role);
        }
        var cRole = document.getElementById('cardRole');
        cRole.style.opacity       = isSelf ? '0.45' : '1';
        cRole.style.pointerEvents = isSelf ? 'none'  : '';

        /* Manager card */
        document.getElementById('managerUserId').value = userId;
        var ms = document.getElementById('managerSelect');
        for (var j = 0; j < ms.options.length; j++) {
            ms.options[j].selected = (ms.options[j].value === manager);
        }
        document.getElementById('cardManager').style.display =
            role === 'EMP' ? '' : 'none';

        /* Status card */
        document.getElementById('toggleUserId').value    = userId;
        document.getElementById('toggleActiveVal').value = active ? '0' : '1';
        var badge = document.getElementById('statusBadge');
        badge.textContent = active ? 'Active' : 'Inactive';
        badge.className   = 'badge ' + (active ? 'bg-success' : 'bg-danger');
        var btn = document.getElementById('toggleBtn');
        btn.textContent = active ? 'Deactivate' : 'Activate';
        btn.className   = 'btn w-100 ' + (active ? 'btn-warning' : 'btn-outline-success');
        var cStatus = document.getElementById('cardStatus');
        cStatus.style.opacity       = isSelf ? '0.45' : '1';
        cStatus.style.pointerEvents = isSelf ? 'none'  : '';

        document.getElementById('selfWarning').style.display = isSelf ? '' : 'none';
    }
    window.loadEditCards = loadEditCards;

    /* ── "Edit" button from Show tab ── */
    window.openEditTab = function (userId) {
        bootstrap.Tab.getOrCreateInstance(
            document.getElementById('editTabBtn')
        ).show();
        var sel = document.getElementById('editUserSelect');
        sel.value = String(userId);
        loadEditCards();
    };

    /* ── FILTER LOGIC ── */
    window.applyFilters = function () {
        var search = document.getElementById('filterSearch').value.toLowerCase().trim();
        var role   = document.getElementById('filterRole').value;
        var dept   = document.getElementById('filterDept').value.toLowerCase();
        var status = document.getElementById('filterStatus').value;

        var rows  = document.querySelectorAll('#employeeTableBody tr');
        var shown = 0;

        rows.forEach(function (row) {
            var rowSearch = (row.getAttribute('data-search') || '').toLowerCase();
            var rowRole   = (row.getAttribute('data-role')   || '');
            var rowDept   = (row.getAttribute('data-dept')   || '').toLowerCase();
            var rowStatus = (row.getAttribute('data-status') || '');

            var matchSearch = !search || rowSearch.includes(search);
            var matchRole   = !role   || rowRole   === role;
            var matchDept   = !dept   || rowDept   === dept;
            var matchStatus = !status || rowStatus === status;

            var visible = matchSearch && matchRole && matchDept && matchStatus;
            row.style.display = visible ? '' : 'none';
            if (visible) shown++;
        });

        var countEl = document.getElementById('filterCount');
        if (search || role || dept || status) {
            countEl.textContent = 'Showing ' + shown + ' of ' + rows.length + ' employees';
        } else {
            countEl.textContent = '';
        }
    };

    window.clearFilters = function () {
        document.getElementById('filterSearch').value = '';
        document.getElementById('filterRole').value   = '';
        document.getElementById('filterDept').value   = '';
        document.getElementById('filterStatus').value = '';
        applyFilters();
    };

})();
</script>
