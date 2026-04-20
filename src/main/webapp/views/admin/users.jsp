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
    <p>Create employees, managers, and administrators.</p>
  </section>

  <form method="post" action="${pageContext.request.contextPath}/admin/users" class="panel user-form">
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
      <tr><th>Code</th><th>Name</th><th>Email</th><th>Role</th><th>Department</th></tr>
    </thead>
    <tbody>
      <c:forEach var="u" items="${users}">
        <tr>
          <td>${u.employeeCode}</td>
          <td>${u.fullName}</td>
          <td>${u.email}</td>
          <td>${u.role}</td>
          <td>${u.departmentName}</td>
        </tr>
      </c:forEach>
    </tbody>
  </table>
</main>
</body>
</html>
