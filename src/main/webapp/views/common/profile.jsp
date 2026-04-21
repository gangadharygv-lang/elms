<%@ page contentType="text/html;charset=UTF-8" import="com.elms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    User u = (User) session.getAttribute("user");

    String initials   = (u != null && u.getFullName() != null && !u.getFullName().isEmpty())
                        ? String.valueOf(u.getFullName().charAt(0)).toUpperCase() : "?";

    String memberSince = (u != null && u.getCreatedAt() != null)
                        ? u.getCreatedAt().toLocalDate().toString() : "";

    String deptName   = (u != null && u.getDepartmentName() != null) ? u.getDepartmentName() : "";

    String roleLabel  = "";
    if (u != null && u.getRole() != null) {
        switch (u.getRole()) {
            case EMP:   roleLabel = "Employee";      break;
            case MGR:   roleLabel = "Manager";       break;
            case ADMIN: roleLabel = "Administrator"; break;
        }
    }

    String flashKey = (String) session.getAttribute("flashKey");
    String flashMsg = (String) session.getAttribute("flashMsg");
    session.removeAttribute("flashKey");
    session.removeAttribute("flashMsg");
    if (flashKey == null) flashKey = "";
    if (flashMsg == null) flashMsg = "";
%>

<h2 class="mb-4">My Profile</h2>

<% if (flashKey.equals("profileSuccess") || flashKey.equals("pwdSuccess")) { %>
<div class="alert alert-success alert-dismissible fade show">
    <%= flashMsg %>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
<% } %>
<% if (flashKey.equals("error") || flashKey.equals("pwdError")) { %>
<div class="alert alert-danger alert-dismissible fade show">
    <%= flashMsg %>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
<% } %>

<div class="row g-4">

    <!-- LEFT -->
    <div class="col-md-4">
        <div class="card shadow-sm h-100">
            <div class="card-body text-center py-4">
                <div class="rounded-circle bg-success text-white d-inline-flex
                            align-items-center justify-content-center mb-3"
                     style="width:80px;height:80px;font-size:2rem;font-weight:700;">
                    <%= initials %>
                </div>
                <h5 class="card-title mb-1">${sessionScope.user.fullName}</h5>
                <p class="text-muted small mb-1">${sessionScope.user.email}</p>
                <span class="badge bg-success mb-3"><%= roleLabel %></span>

                <ul class="list-group list-group-flush text-start mt-2">
                    <li class="list-group-item d-flex justify-content-between">
                        <span class="text-muted">Employee Code</span>
                        <strong>${sessionScope.user.employeeCode}</strong>
                    </li>
                    <% if (!deptName.isEmpty()) { %>
                    <li class="list-group-item d-flex justify-content-between">
                        <span class="text-muted">Department</span>
                        <strong><%= deptName %></strong>
                    </li>
                    <% } %>
                    <li class="list-group-item d-flex justify-content-between">
                        <span class="text-muted">Member Since</span>
                        <strong><%= memberSince %></strong>
                    </li>
                </ul>
            </div>
        </div>
    </div>

    <!-- RIGHT -->
    <div class="col-md-8">

        <!-- EDIT PROFILE -->
        <div class="card shadow-sm mb-4">
            <div class="card-header fw-semibold">Edit Profile</div>
            <div class="card-body">
                <form method="post" action="${pageContext.request.contextPath}/profile" class="row g-3">
                    <input type="hidden" name="action" value="updateProfile"/>
                    <div class="col-md-6">
                        <label class="form-label">Full Name</label>
                        <input type="text" class="form-control" name="fullName"
                               value="${sessionScope.user.fullName}" required/>
                    </div>
                   <div class="col-md-6">
    <label class="form-label">Email</label>
    <input type="email" class="form-control"
           value="${sessionScope.user.email}" readonly/>
    <div class="form-text">Email cannot be changed.</div>
</div>
                    <div class="col-12">
                        <button class="btn btn-success">Save Changes</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- CHANGE PASSWORD (UPDATED) -->
        <div class="card shadow-sm">
            <div class="card-header d-flex justify-content-between align-items-center">
                <span class="fw-semibold">Security</span>
                <button class="btn btn-sm btn-outline-primary"
                        onclick="togglePasswordCard()">
                    Change Password
                </button>
            </div>

            <div class="card-body" id="passwordCard" style="display:none;">
                <form method="post" action="${pageContext.request.contextPath}/profile" class="row g-3">
                    <input type="hidden" name="action" value="changePassword"/>

                    <div class="col-12">
                        <label class="form-label">Current Password</label>
                        <div class="input-group">
                            <input type="password" class="form-control" name="currentPassword" id="currentPassword" required/>
                            <button class="btn btn-outline-secondary" type="button"
                                    onclick="togglePwd('currentPassword',this)">Show</button>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label">New Password</label>
                        <div class="input-group">
                            <input type="password" class="form-control" name="newPassword"
                                   id="newPassword" required oninput="checkMatch()"/>
                            <button class="btn btn-outline-secondary" type="button"
                                    onclick="togglePwd('newPassword',this)">Show</button>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label">Confirm Password</label>
                        <div class="input-group">
                            <input type="password" class="form-control" name="confirmPassword"
                                   id="confirmPassword" required oninput="checkMatch()"/>
                            <button class="btn btn-outline-secondary" type="button"
                                    onclick="togglePwd('confirmPassword',this)">Show</button>
                        </div>
                        <div id="matchFeedback" class="form-text"></div>
                    </div>

                    <div class="col-12 d-flex gap-2">
                        <button class="btn btn-warning" id="pwdSubmitBtn">Update Password</button>
                        <button type="button" class="btn btn-secondary"
                                onclick="togglePasswordCard()">Cancel</button>
                    </div>
                </form>
            </div>
        </div>

    </div>
</div>

<script>
function togglePwd(id, btn) {
    var inp = document.getElementById(id);
    inp.type = inp.type === 'password' ? 'text' : 'password';
    btn.textContent = inp.type === 'password' ? 'Show' : 'Hide';
}

function checkMatch() {
    var np = document.getElementById('newPassword').value;
    var cp = document.getElementById('confirmPassword').value;
    var fb = document.getElementById('matchFeedback');
    var btn = document.getElementById('pwdSubmitBtn');

    if (!cp) { fb.textContent = ''; btn.disabled = false; return; }

    if (np === cp) {
        fb.textContent = 'Passwords match';
        fb.className = 'form-text text-success';
        btn.disabled = false;
    } else {
        fb.textContent = 'Passwords do not match';
        fb.className = 'form-text text-danger';
        btn.disabled = true;
    }
}

function togglePasswordCard() {
    const card = document.getElementById("passwordCard");
    card.style.display = card.style.display === "none" ? "block" : "none";
}
</script>