<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ELMS Analytics</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<jsp:include page="partials-nav.jsp"/>
<main class="page">
  <section class="page-title">
    <h1>Analytics</h1>
    <p>Leave utilization by status, type, department, and month.</p>
  </section>

  <div class="analytics-grid">
    <section class="panel">
      <h2>Status</h2>
      <c:forEach var="s" items="${statusStats}">
        <div class="bar-row"><span>${s.key}</span><strong style="width:${s.value * 12}px">${s.value}</strong></div>
      </c:forEach>
    </section>
    <section class="panel">
      <h2>Leave Type</h2>
      <c:forEach var="s" items="${typeStats}">
        <div class="bar-row"><span>${s.key}</span><strong style="width:${s.value * 12}px">${s.value}</strong></div>
      </c:forEach>
    </section>
    <section class="panel">
      <h2>Department</h2>
      <c:forEach var="s" items="${departmentStats}">
        <div class="bar-row"><span>${s.key}</span><strong style="width:${s.value * 12}px">${s.value}</strong></div>
      </c:forEach>
    </section>
    <section class="panel">
      <h2>Monthly Trend</h2>
      <c:forEach var="s" items="${monthlyStats}">
        <div class="bar-row"><span>${s.key}</span><strong style="width:${s.value * 12}px">${s.value}</strong></div>
      </c:forEach>
    </section>
  </div>

  <h2>Recent Activity</h2>
  <table>
    <thead>
      <tr><th>Employee</th><th>Type</th><th>Dates</th><th>Status</th></tr>
    </thead>
    <tbody>
      <c:forEach var="r" items="${recentRequests}">
        <tr>
          <td>${r.employeeName}</td>
          <td>${r.leaveTypeCode}</td>
          <td>${r.startDate} to ${r.endDate}</td>
          <td><span class="status ${r.status}">${r.status}</span></td>
        </tr>
      </c:forEach>
    </tbody>
  </table>
</main>
</body>
</html>
