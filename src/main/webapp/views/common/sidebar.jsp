<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<div class="sidebar bg-dark text-white p-3">
    <h5 class="mb-4">Menu</h5>

    <%-- EMPLOYEE --%>
    <c:if test="${sessionScope.user.role.name() == 'EMP'}">
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/leave/apply">Apply Leave</a>
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/leave/my-requests">My Leaves</a>
        <hr class="border-secondary my-2"/>
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/profile">My Profile</a>
    </c:if>

    <%-- MANAGER --%>
    <c:if test="${sessionScope.user.role.name() == 'MGR'}">
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/manager/approvals">Approvals</a>
        <hr class="border-secondary my-2"/>
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/profile">My Profile</a>
    </c:if>

    <%-- ADMIN --%>
    <c:if test="${sessionScope.user.role.name() == 'ADMIN'}">
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/admin/users">Users</a>
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/admin/reports">Reports</a>
        <hr class="border-secondary my-2"/>
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/profile">My Profile</a>
    </c:if>
</div>
