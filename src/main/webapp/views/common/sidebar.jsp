<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<div class="sidebar bg-dark text-white p-3">
    <h5 class="mb-4">Menu</h5>

    <%-- EMPLOYEE --%>
    <c:if test="${sessionScope.user.role.name() == 'EMP'}">
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
        <%-- FIX: was linking directly to JSP files which bypass AuthFilter and miss model data.
             Must link to servlets (/leave/apply, /leave/my-requests) --%>
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/leave/apply">Apply Leave</a>
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/leave/my-requests">My Leaves</a>
    </c:if>

    <%-- MANAGER --%>
    <c:if test="${sessionScope.user.role.name() == 'MGR'}">
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
        <%-- FIX: was linking to /views/manager/dashboard.jsp (direct JSP, no auth, no data).
             Approvals page is served by ApprovalServlet at /manager/approvals --%>
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/manager/approvals">Approvals</a>
    </c:if>

    <%-- ADMIN --%>
    <c:if test="${sessionScope.user.role.name() == 'ADMIN'}">
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
        <%-- FIX: was linking to /views/admin/manage-users.jsp — no auth, no data.
             Must go through servlets --%>
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/admin/users">Users</a>
        <a class="nav-link text-white" href="${pageContext.request.contextPath}/admin/reports">Reports</a>
    </c:if>
</div>
