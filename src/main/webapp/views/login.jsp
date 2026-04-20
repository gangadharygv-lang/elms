<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ELMS Login</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="login-page">
  <main class="login-panel">
    <h1>ELMS</h1>
    <p>Enterprise Leave Management System</p>

    <c:if test="${not empty error}">
      <div class="alert error">${error}</div>
    </c:if>
    <c:if test="${param.timeout == 'true'}">
      <div class="alert warning">Session timed out. Please log in again.</div>
    </c:if>

    <form method="post" action="${pageContext.request.contextPath}/login">
      <label>Email Address</label>
      <input type="email" name="email" placeholder="admin@elms.local" required autofocus>
      <label>Password</label>
      <input type="password" name="password" placeholder="password123" required>
      <button type="submit">Login</button>
    </form>
  </main>
</body>
</html>
