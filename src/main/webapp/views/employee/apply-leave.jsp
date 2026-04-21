<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<h2 class="mb-4">Apply Leave</h2>

<%-- FIX: error message from redirectError() arrives as a URL query param.
     Original used ${param.error} directly — XSS risk (raw HTML in output).
     c:out escapes it safely. --%>
<c:if test="${not empty param.error}">
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <strong>Error:</strong> <c:out value="${param.error}"/>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>

<div class="card shadow-sm">
    <div class="card-body">
        <form method="post"
              action="${pageContext.request.contextPath}/leave/apply"
              enctype="multipart/form-data"
              class="row g-3">

            <%-- Leave Type --%>
            <div class="col-md-4">
                <label class="form-label fw-semibold">Leave Type <span class="text-danger">*</span></label>
                <select class="form-select" name="leaveTypeId" required
                        onchange="checkBalance(this)">
                    <option value="" disabled selected>-- Select Leave Type --</option>
                    <c:forEach var="t" items="${leaveTypes}">
                        <%-- FIX: original used ${t.name} but the getter is getTypeName().
                             Use ${t.typeName} to match the actual model property. --%>
                        <option value="${t.typeId}" data-balance="${t.balanceRemaining}">
                            ${t.typeName} (Balance: ${t.balanceRemaining} days)
                        </option>
                    </c:forEach>
                </select>
                <div id="balanceHint" class="form-text"></div>
            </div>

            <%-- Session --%>
            <div class="col-md-4">
                <label class="form-label fw-semibold">Session <span class="text-danger">*</span></label>
                <%-- FIX: enum values are FULL, FIRST_HALF, SECOND_HALF — not "HALF" --%>
                <select class="form-select" name="session" id="sessionSelect"
                        onchange="toggleEndDate()">
                    <option value="FULL">Full Day</option>
                    <option value="FIRST_HALF">First Half</option>
                    <option value="SECOND_HALF">Second Half</option>
                </select>
            </div>

            <%-- Start Date --%>
            <div class="col-md-4">
                <label class="form-label fw-semibold">Start Date <span class="text-danger">*</span></label>
                <%-- FIX: added min=today so browser blocks past-date selection --%>
                <input type="date" class="form-control" name="startDate" id="startDate"
                       required onchange="syncEndDateMin()">
            </div>

            <%-- End Date (hidden for half-day) --%>
            <div class="col-md-4" id="endDateGroup">
                <label class="form-label fw-semibold">End Date <span class="text-danger">*</span></label>
                <input type="date" class="form-control" name="endDate" id="endDate" required>
            </div>

            <%-- Reason --%>
            <div class="col-12">
                <label class="form-label fw-semibold">Reason <span class="text-danger">*</span></label>
                <textarea class="form-control" name="reason" rows="3" required
                          placeholder="Brief reason for leave"></textarea>
            </div>

            <%-- Attachment --%>
            <div class="col-12">
                <label class="form-label fw-semibold">
                    Attachment
                    <span class="text-muted fw-normal">(PDF or JPG — required for some leave types)</span>
                </label>
                <input type="file" class="form-control" name="attachment" accept=".pdf,.jpg,.jpeg">
                <div class="form-text">Max size: 5 MB</div>
            </div>

            <%-- Buttons --%>
            <div class="col-12 d-flex gap-2">
                <button type="submit" class="btn btn-success">&#10003; Submit Leave Request</button>
                <a href="${pageContext.request.contextPath}/dashboard"
                   class="btn btn-outline-secondary">Cancel</a>
            </div>

        </form>
    </div>
</div>

<script>
    // Set today as minimum selectable date
    const today = new Date().toISOString().split('T')[0];
    document.getElementById('startDate').setAttribute('min', today);
    document.getElementById('endDate').setAttribute('min', today);

    function syncEndDateMin() {
        const s = document.getElementById('startDate').value;
        const e = document.getElementById('endDate');
        e.setAttribute('min', s || today);
        if (e.value && e.value < s) e.value = s;
        // Mirror into endDate if half-day mode
        const sv = document.getElementById('sessionSelect').value;
        if (sv === 'FIRST_HALF' || sv === 'SECOND_HALF') {
            e.value = s;
        }
    }

    // FIX: FIRST_HALF / SECOND_HALF must be same-day — hide endDate and mirror startDate.
    function toggleEndDate() {
        const v      = document.getElementById('sessionSelect').value;
        const isHalf = v === 'FIRST_HALF' || v === 'SECOND_HALF';
        const grp    = document.getElementById('endDateGroup');
        const endInp = document.getElementById('endDate');
        if (isHalf) {
            grp.style.display = 'none';
            endInp.value = document.getElementById('startDate').value;
            endInp.removeAttribute('required');
        } else {
            grp.style.display = '';
            endInp.setAttribute('required', 'required');
        }
    }

    // Show live balance feedback when leave type is selected
    function checkBalance(sel) {
        const opt     = sel.options[sel.selectedIndex];
        const balance = parseFloat(opt.dataset.balance || 0);
        const hint    = document.getElementById('balanceHint');
        if (!opt.value) { hint.textContent = ''; return; }
        hint.textContent = 'Available: ' + balance + ' day(s)';
        hint.className   = balance > 0 ? 'form-text text-success fw-semibold'
                                       : 'form-text text-danger fw-semibold';
    }
</script>
