<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <%-- FIX: added responsive viewport meta tag (was missing) --%>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${pageTitle}</title>
    <jsp:include page="/views/common/bootstrap.jsp"/>
</head>
<body>

<jsp:include page="/views/common/topbar.jsp"/>

<%-- FIX: removed leftover debug <h1>LAYOUT WORKING</h1> that appeared on every page --%>

<div class="layout">
    <jsp:include page="/views/common/sidebar.jsp"/>
    <div class="main">
        <jsp:include page="${contentPage}"/>
    </div>
</div>

<jsp:include page="/views/common/footer.jsp"/>
<jsp:include page="/views/common/bootstrap-js.jsp"/>

</body>
</html>
