<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<div class="sidebar bg-dark text-white p-3">
    <h5 class="mb-4">Menu</h5>

    <%-- EMPLOYEE --%>
    <c:if test="${sessionScope.user.role.name() == 'EMP'}">
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/dashboard">&#127968; Dashboard</a>
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/leave/apply">&#128196; Apply Leave</a>
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/leave/my-requests">&#128203; My Leaves</a>
        <hr class="border-secondary my-2"/>
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/profile">&#128100; My Profile</a>
    </c:if>

    <%-- MANAGER --%>
    <c:if test="${sessionScope.user.role.name() == 'MGR'}">
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/dashboard">&#127968; Dashboard</a>
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/manager/approvals">&#9989; Approvals</a>
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/manager/analytics">&#128200; Analytics</a>
        <hr class="border-secondary my-2"/>
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/profile">&#128100; My Profile</a>
    </c:if>

    <%-- ADMIN --%>
    <c:if test="${sessionScope.user.role.name() == 'ADMIN'}">
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/dashboard">&#127968; Dashboard</a>
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/admin/users">&#128101; Manage Users</a>
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/admin/analytics">&#128200; Analytics</a>
        <hr class="border-secondary my-2"/>
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/profile">&#128100; My Profile</a>
    </c:if>
</div>
