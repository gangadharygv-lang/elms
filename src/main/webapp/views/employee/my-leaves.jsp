<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<h2 class="mb-4">My Leave Requests</h2>

<c:if test="${empty requests}">
    <div class="alert alert-info">No leave requests found.</div>
</c:if>

<c:if test="${not empty requests}">
    <%-- FIX: wrapped in table-responsive to prevent horizontal overflow --%>
    <div class="table-responsive">
        <table class="table table-bordered table-striped align-middle">
            <thead class="table-dark">
                <tr>
                    <th>Type</th>
                    <th>Dates</th>
                    <th>Days</th>
                    <th>Status</th>
                    <th>Remarks</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="r" items="${requests}">
                    <tr>
                        <td>${r.leaveTypeCode}</td>
                        <%-- FIX: original had a raw newline between startDate and endDate
                             which rendered as a visible line break inside the <td> --%>
                        <td>${r.startDate} to ${r.endDate}</td>
                        <td>${r.durationDays}</td>
                        <td>
                            <span class="badge
                                ${r.status == 'APPROVED' ? 'bg-success' :
                                  r.status == 'REJECTED' ? 'bg-danger' :
                                  'bg-warning text-dark'}">
                                ${r.status}
                            </span>
                        </td>
                        <td>${r.managerRemarks}</td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</c:if>

<a href="${pageContext.request.contextPath}/leave/apply"
   class="btn btn-primary mt-3">
   Apply New Leave
</a>
