<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Leave Requests</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<jsp:include page="partials-nav.jsp"/>
<main class="page">
  <section class="page-title">
    <h1>My Requests</h1>
    <p>Track submitted, approved, rejected, and cancelled leave.</p>
  </section>
  <c:if test="${param.success == 'cancelled'}">
    <div class="alert success">Pending request cancelled.</div>
  </c:if>
  <table>
    <thead>
      <tr><th>Type</th><th>Dates</th><th>Days</th><th>Status</th><th>Action</th></tr>
    </thead>
    <tbody>
      <c:forEach var="r" items="${requests}">
        <tr>
          <td>${r.leaveTypeName}</td>
          <td>${r.startDate} to ${r.endDate}</td>
          <td>${r.durationDays}</td>
          <td><span class="status ${r.status}">${r.status}</span></td>
          <td>
            <c:if test="${r.status == 'PENDING'}">
              <form method="post" action="${pageContext.request.contextPath}/leave/my-requests" class="inline">
                <input type="hidden" name="requestId" value="${r.requestId}">
                <button type="submit" class="secondary">Cancel</button>
              </form>
            </c:if>
          </td>
        </tr>
      </c:forEach>
    </tbody>
  </table>
</main>
</body>
</html>
