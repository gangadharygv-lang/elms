<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - ELMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="login-page">
<main class="login-panel">
    <h1>ELMS</h1>
    <p>Choose a new password</p>

    <c:if test="${not empty error}">
        <div class="alert error"><c:out value="${error}"/></div>
    </c:if>

    <c:if test="${not empty token}">
        <form method="post" action="${pageContext.request.contextPath}/reset-password">
            <input type="hidden" name="token" value="${token}"/>

            <label>New Password</label>
            <input type="password" name="newPassword" id="newPassword"
                   placeholder="••••••••" required minlength="6">

            <label>Confirm New Password</label>
            <input type="password" name="confirmPassword" id="confirmPassword"
                   placeholder="••••••••" required minlength="6"
                   oninput="checkMatch()">
            <small id="matchFeedback" style="display:block;margin-top:-8px;margin-bottom:8px;"></small>

            <button type="submit" id="submitBtn">Set New Password</button>
        </form>
    </c:if>

    <c:if test="${empty token && empty error}">
        <p style="color:#666;">No reset token provided.</p>
    </c:if>

    <div style="margin-top:16px;text-align:center;">
        <a href="${pageContext.request.contextPath}/login" style="color:#198754;font-size:0.9rem;">
            &larr; Back to Login
        </a>
        &nbsp;|&nbsp;
        <a href="${pageContext.request.contextPath}/forgot-password" style="color:#198754;font-size:0.9rem;">
            Request new link
        </a>
    </div>
</main>
<script>
function checkMatch() {
    var np = document.getElementById('newPassword').value;
    var cp = document.getElementById('confirmPassword').value;
    var fb = document.getElementById('matchFeedback');
    var btn = document.getElementById('submitBtn');
    if (!cp) { fb.textContent = ''; btn.disabled = false; return; }
    if (np === cp) {
        fb.textContent = 'Passwords match';
        fb.style.color = 'green';
        btn.disabled = false;
    } else {
        fb.textContent = 'Passwords do not match';
        fb.style.color = 'red';
        btn.disabled = true;
    }
}
</script>
</body>
</html>