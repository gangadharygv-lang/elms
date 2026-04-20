<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Manage Users</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<jsp:include page="../partials-nav.jsp"/>
<main class="page">
  <section class="page-title">
    <h1>Users</h1>
    <p>Create, edit, activate, and deactivate user accounts.</p>
  </section>

  <c:if test="${not empty param.success}">
    <div class="alert success">User action completed successfully.</div>
  </c:if>

  <form method="post" action="${pageContext.request.contextPath}/admin/users" class="panel user-form">
    <input type="hidden" name="action" value="create">
    <input name="employeeCode" placeholder="Employee code" required>
    <input name="fullName" placeholder="Full name" required>
    <input type="email" name="email" placeholder="Email" required>
    <input type="password" name="password" placeholder="Temporary password" required>
    <select name="role">
      <option value="EMP">Employee</option>
      <option value="MGR">Manager</option>
      <option value="ADMIN">Admin</option>
    </select>
    <button type="submit">Create User</button>
  </form>

  <table>
    <thead>
      <tr><th>Code</th><th>Name</th><th>Email</th><th>Role</th><th>Status</th><th>Edit</th><th>Action</th></tr>
    </thead>
    <tbody>
      <c:forEach var="u" items="${users}">
        <tr>
          <td>${u.employeeCode}</td>
          <td>${u.fullName}</td>
          <td>${u.email}</td>
          <td>${u.role}</td>
          <td>
            <c:choose>
              <c:when test="${u.active}"><span class="status APPROVED">Active</span></c:when>
              <c:otherwise><span class="status CANCELLED">Inactive</span></c:otherwise>
            </c:choose>
          </td>
          <td>
            <form method="post" action="${pageContext.request.contextPath}/admin/users" class="compact-edit">
              <input type="hidden" name="action" value="update">
              <input type="hidden" name="userId" value="${u.userId}">
              <input name="employeeCode" value="${u.employeeCode}" required aria-label="Employee code">
              <input name="fullName" value="${u.fullName}" required aria-label="Full name">
              <input type="email" name="email" value="${u.email}" required aria-label="Email">
              <select name="role">
                <c:choose>
                  <c:when test="${u.role == 'EMP'}"><option value="EMP" selected>Employee</option></c:when>
                  <c:otherwise><option value="EMP">Employee</option></c:otherwise>
                </c:choose>
                <c:choose>
                  <c:when test="${u.role == 'MGR'}"><option value="MGR" selected>Manager</option></c:when>
                  <c:otherwise><option value="MGR">Manager</option></c:otherwise>
                </c:choose>
                <c:choose>
                  <c:when test="${u.role == 'ADMIN'}"><option value="ADMIN" selected>Admin</option></c:when>
                  <c:otherwise><option value="ADMIN">Admin</option></c:otherwise>
                </c:choose>
              </select>
              <select name="active">
                <c:choose>
                  <c:when test="${u.active}"><option value="1" selected>Active</option></c:when>
                  <c:otherwise><option value="1">Active</option></c:otherwise>
                </c:choose>
                <c:choose>
                  <c:when test="${!u.active}"><option value="0" selected>Inactive</option></c:when>
                  <c:otherwise><option value="0">Inactive</option></c:otherwise>
                </c:choose>
              </select>
              <input type="password" name="password" placeholder="New password optional">
              <button type="submit">Save</button>
            </form>
          </td>
          <td>
            <form method="post" action="${pageContext.request.contextPath}/admin/users" class="inline">
              <input type="hidden" name="action" value="toggle">
              <input type="hidden" name="userId" value="${u.userId}">
              <c:choose>
                <c:when test="${u.active}">
                  <input type="hidden" name="active" value="0">
                  <button type="submit" class="danger">Deactivate</button>
                </c:when>
                <c:otherwise>
                  <input type="hidden" name="active" value="1">
                  <button type="submit">Activate</button>
                </c:otherwise>
              </c:choose>
            </form>
          </td>
        </tr>
      </c:forEach>
    </tbody>
  </table>
</main>
</body>
</html>
