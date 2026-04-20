<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<nav class="topbar">
  <a class="brand" href="${pageContext.request.contextPath}/dashboard">ELMS</a>
  <div>
    <a href="${pageContext.request.contextPath}/leave/apply">Apply Leave</a>
    <a href="${pageContext.request.contextPath}/leave/my-requests">My Requests</a>
    <c:if test="${sessionScope.user.role == 'MGR' || sessionScope.user.role == 'ADMIN'}">
      <a href="${pageContext.request.contextPath}/manager/approvals">Approvals</a>
      <a href="${pageContext.request.contextPath}/manager/analytics">Analytics</a>
    </c:if>
    <c:if test="${sessionScope.user.role == 'ADMIN'}">
      <a href="${pageContext.request.contextPath}/admin/users">Users</a>
    </c:if>
    <a href="${pageContext.request.contextPath}/logout">Logout</a>
  </div>
</nav>
