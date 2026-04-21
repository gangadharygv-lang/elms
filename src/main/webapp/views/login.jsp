<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <%-- FIX: added viewport meta (was missing, caused bad mobile rendering) --%>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ELMS Login</title>
    <%-- FIX: Bootstrap was not included in login.jsp at all — it uses custom .login-panel
         styles from style.css, but Bootstrap utilities like .alert were also absent,
         so the session-timeout warning had no styling. Now including both. --%>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="login-page">
    <main class="login-panel">
        <h1>ELMS</h1>
        <p>Enterprise Leave Management System</p>

        <%-- FIX: original used ${error} directly without c:out — XSS risk if error message
             contains HTML characters. Use c:out to safely escape. --%>
        <c:if test="${not empty error}">
            <div class="alert error"><c:out value="${error}"/></div>
        </c:if>

        <c:if test="${param.timeout == 'true'}">
            <div class="alert warning">Session timed out. Please log in again.</div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/login">
            <label>Email Address</label>
            <input type="email" name="email" placeholder="admin@elms.local" required autofocus>

            <label>Password</label>
            <input type="password" name="password" placeholder="••••••••" required>

            <button type="submit">Login</button>
        </form>
    </main>
</body>
</html>
