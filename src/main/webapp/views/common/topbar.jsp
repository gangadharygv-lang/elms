<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<nav class="navbar navbar-dark bg-success px-4">

    <span class="navbar-brand fw-bold">ELMS</span>

    <div class="d-flex align-items-center gap-3 text-white">
        <span>${sessionScope.user.fullName}</span>
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-light btn-sm">
            Logout
        </a>
    </div>

</nav>