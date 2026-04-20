<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ELMS Dashboard</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<jsp:include page="partials-nav.jsp"/>
<main class="page">
  <section class="page-title">
    <h1>Welcome, ${sessionScope.user.fullName}</h1>
    <p>${sessionScope.user.role} · ${sessionScope.user.departmentName}</p>
  </section>

  <c:if test="${param.success == 'leave-submitted'}">
    <div class="alert success">Leave request submitted for manager review.</div>
  </c:if>

  <h2>Leave Balance</h2>
  <div class="cards">
    <c:forEach var="b" items="${balances}">
      <article class="card">
        <strong>${b.leaveTypeCode}</strong>
        <h3>${b.daysRemaining} days</h3>
        <p>${b.leaveTypeName} · Taken ${b.daysTaken}</p>
      </article>
    </c:forEach>
  </div>

  <h2>Recent Requests</h2>
  <table>
    <thead>
      <tr><th>Type</th><th>Dates</th><th>Days</th><th>Status</th><th>Remarks</th></tr>
    </thead>
    <tbody>
      <c:forEach var="r" items="${requests}">
        <tr>
          <td>${r.leaveTypeCode}</td>
          <td>${r.startDate} to ${r.endDate}</td>
          <td>${r.durationDays}</td>
          <td><span class="status ${r.status}">${r.status}</span></td>
          <td>${r.managerRemarks}</td>
        </tr>
      </c:forEach>
    </tbody>
  </table>
</main>
</body>
</html>
