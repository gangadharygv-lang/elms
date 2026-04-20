<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Approval Queue</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<jsp:include page="partials-nav.jsp"/>
<main class="page">
  <section class="page-title">
    <h1>Approval Queue</h1>
    <p>Review pending requests from your reportees.</p>
  </section>
  <c:if test="${param.success == 'updated'}">
    <div class="alert success">Request updated successfully.</div>
  </c:if>
  <c:if test="${param.error == 'remarks-required'}">
    <div class="alert error">Manager remarks are required.</div>
  </c:if>
  <table>
    <thead>
      <tr><th>Employee</th><th>Type</th><th>Dates</th><th>Days</th><th>Reason</th><th>Decision</th></tr>
    </thead>
    <tbody>
      <c:forEach var="r" items="${requests}">
        <tr>
          <td>${r.employeeName}<br><small>${r.departmentName}</small></td>
          <td>${r.leaveTypeCode}</td>
          <td>${r.startDate} to ${r.endDate}</td>
          <td>${r.durationDays}</td>
          <td>${r.reason}</td>
          <td>
            <form method="post" action="${pageContext.request.contextPath}/manager/approvals" class="decision">
              <input type="hidden" name="requestId" value="${r.requestId}">
              <input type="text" name="remarks" placeholder="Remarks" required>
              <button name="action" value="approve" type="submit">Approve</button>
              <button name="action" value="reject" type="submit" class="danger">Reject</button>
            </form>
          </td>
        </tr>
      </c:forEach>
    </tbody>
  </table>
</main>
</body>
</html>
