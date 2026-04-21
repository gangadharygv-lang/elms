<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password - ELMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="login-page">
<main class="login-panel">
    <h1>ELMS</h1>
    <p>Reset your password</p>

    <c:if test="${not empty error}">
        <div class="alert error"><c:out value="${error}"/></div>
    </c:if>
    <c:if test="${not empty success}">
        <div class="alert alert-success" style="background:#d1e7dd;color:#0a3622;padding:10px;border-radius:6px;margin-bottom:12px;">
            <c:out value="${success}"/>
        </div>
    </c:if>

    <c:if test="${empty success}">
        <form method="post" action="${pageContext.request.contextPath}/forgot-password">
            <label>Email Address</label>
            <input type="email" name="email" placeholder="your@email.com" required autofocus>
            <button type="submit">Send Reset Link</button>
        </form>
    </c:if>

    <div style="margin-top:16px;text-align:center;">
        <a href="${pageContext.request.contextPath}/login" style="color:#198754;font-size:0.9rem;">
            &larr; Back to Login
        </a>
    </div>
</main>
</body>
</html>