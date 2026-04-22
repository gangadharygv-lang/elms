<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<h2 class="mb-1">Analytics Dashboard</h2>
<p class="text-muted mb-4">Organisation-wide leave intelligence for <strong>${sessionScope.user.fullName}</strong></p>

<%-- ══════════════════════════════════════════════════════════
     KPI CARDS
═══════════════════════════════════════════════════════════ --%>
<div class="row g-3 mb-4">
    <div class="col-6 col-md-4 col-xl-2">
        <div class="card text-center border-0 shadow-sm h-100" style="background:#e8f5e9;">
            <div class="card-body py-3">
                <div class="fs-2 fw-bold text-success">${kpi.totalEmployees}</div>
                <div class="small text-muted">Total Employees</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-md-4 col-xl-2">
        <div class="card text-center border-0 shadow-sm h-100" style="background:#e3f2fd;">
            <div class="card-body py-3">
                <div class="fs-2 fw-bold text-primary">${kpi.totalRequests}</div>
                <div class="small text-muted">Total Requests</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-md-4 col-xl-2">
        <div class="card text-center border-0 shadow-sm h-100" style="background:#fff8e1;">
            <div class="card-body py-3">
                <div class="fs-2 fw-bold text-warning">${kpi.pending}</div>
                <div class="small text-muted">Pending</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-md-4 col-xl-2">
        <div class="card text-center border-0 shadow-sm h-100" style="background:#e8f5e9;">
            <div class="card-body py-3">
                <div class="fs-2 fw-bold text-success">${kpi.approved}</div>
                <div class="small text-muted">Approved</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-md-4 col-xl-2">
        <div class="card text-center border-0 shadow-sm h-100" style="background:#fce4ec;">
            <div class="card-body py-3">
                <div class="fs-2 fw-bold text-danger">${kpi.rejected}</div>
                <div class="small text-muted">Rejected</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-md-4 col-xl-2">
        <div class="card text-center border-0 shadow-sm h-100" style="background:#f3e5f5;">
            <div class="card-body py-3">
                <div class="fs-2 fw-bold text-purple" style="color:#7b1fa2;">${kpi.totalDaysTaken}</div>
                <div class="small text-muted">Total Days Taken</div>
            </div>
        </div>
    </div>
</div>

<%-- ══════════════════════════════════════════════════════════
     CHARTS — ROW 1
═══════════════════════════════════════════════════════════ --%>
<div class="row g-4 mb-4">
    <div class="col-md-4">
        <div class="card shadow-sm h-100">
            <div class="card-header fw-semibold bg-white border-bottom">
                Request Status Distribution
            </div>
            <div class="card-body d-flex align-items-center justify-content-center">
                <canvas id="statusChart" style="max-height:260px;"></canvas>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card shadow-sm h-100">
            <div class="card-header fw-semibold bg-white border-bottom">
                Approved Leaves by Type
            </div>
            <div class="card-body d-flex align-items-center justify-content-center">
                <canvas id="typeChart" style="max-height:260px;"></canvas>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card shadow-sm h-100">
            <div class="card-header fw-semibold bg-white border-bottom">
                Approved Days by Department
            </div>
            <div class="card-body d-flex align-items-center justify-content-center">
                <canvas id="deptChart" style="max-height:260px;"></canvas>
            </div>
        </div>
    </div>
</div>

<%-- CHARTS — ROW 2 (monthly trend - full width) --%>
<div class="row g-4 mb-4">
    <div class="col-12">
        <div class="card shadow-sm">
            <div class="card-header fw-semibold bg-white border-bottom">
                Monthly Approved Leaves — <jsp:scriptlet>out.print(java.time.Year.now().getValue());</jsp:scriptlet>
            </div>
            <div class="card-body">
                <canvas id="monthChart" style="max-height:220px;"></canvas>
            </div>
        </div>
    </div>
</div>

<%-- ══════════════════════════════════════════════════════════
     LEAVE TYPE BALANCE SUMMARY TABLE
═══════════════════════════════════════════════════════════ --%>
<div class="card shadow-sm mb-4">
    <div class="card-header fw-semibold bg-white border-bottom">
        Leave Type Balance Summary (Current Year)
    </div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-bordered table-hover align-middle mb-0">
                <thead class="table-dark">
                    <tr>
                        <th>Leave Type</th>
                        <th>Code</th>
                        <th class="text-center">Total Entitled</th>
                        <th class="text-center">Days Taken</th>
                        <th class="text-center">Days Remaining</th>
                        <th style="min-width:160px;">Utilisation</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="row" items="${typeBalance}">
                        <c:set var="entitled" value="${row[2]}"/>
                        <c:set var="taken"    value="${row[3]}"/>
                        <c:set var="pct"      value="${entitled > 0 ? (taken * 100 / entitled) : 0}"/>
                        <tr>
                            <td>${row[0]}</td>
                            <td><code>${row[1]}</code></td>
                            <td class="text-center">${entitled}</td>
                            <td class="text-center">${taken}</td>
                            <td class="text-center">${row[4]}</td>
                            <td>
                                <div class="d-flex align-items-center gap-2">
                                    <div class="progress flex-grow-1" style="height:10px;">
                                        <div class="progress-bar
                                            ${pct >= 80 ? 'bg-danger' : pct >= 50 ? 'bg-warning' : 'bg-success'}"
                                             style="width:${pct}%"></div>
                                    </div>
                                    <span class="small text-muted">${pct}%</span>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</div>

<%-- ══════════════════════════════════════════════════════════
     TOP LEAVE CONSUMERS TABLE
═══════════════════════════════════════════════════════════ --%>
<div class="card shadow-sm mb-4">
    <div class="card-header fw-semibold bg-white border-bottom">
        Top 10 Leave Consumers (Approved Days)
    </div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-bordered table-hover align-middle mb-0">
                <thead class="table-dark">
                    <tr>
                        <th>#</th>
                        <th>Name</th>
                        <th>Code</th>
                        <th>Department</th>
                        <th class="text-center">Days Taken</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="row" items="${topConsumers}" varStatus="vs">
                        <tr>
                            <td>${vs.index + 1}</td>
                            <td>${row[0]}</td>
                            <td><code>${row[1]}</code></td>
                            <td>${row[2]}</td>
                            <td class="text-center fw-bold">${row[3]}</td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty topConsumers}">
                        <tr><td colspan="5" class="text-center text-muted">No approved leaves yet.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<%-- ══════════════════════════════════════════════════════════
     FULL EMPLOYEE LEAVE SUMMARY TABLE
═══════════════════════════════════════════════════════════ --%>
<div class="card shadow-sm mb-4">
    <div class="card-header fw-semibold bg-white border-bottom d-flex justify-content-between align-items-center">
        <span>All Employees — Leave Summary</span>
        <input type="text" id="empSearch" class="form-control form-control-sm w-auto"
               placeholder="Search name / code…" oninput="filterEmpTable()">
    </div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-bordered table-striped align-middle mb-0" id="empTable">
                <thead class="table-dark">
                    <tr>
                        <th>Name</th>
                        <th>Code</th>
                        <th>Department</th>
                        <th class="text-center">Pending</th>
                        <th class="text-center">Approved</th>
                        <th class="text-center">Rejected</th>
                        <th class="text-center">Days Taken</th>
                    </tr>
                </thead>
                <tbody id="empTbody">
                    <c:forEach var="row" items="${empSummary}">
                        <tr>
                            <td>${row[0]}</td>
                            <td><code>${row[1]}</code></td>
                            <td>${row[2]}</td>
                            <td class="text-center">
                                <c:if test="${row[4] > 0}">
                                    <span class="badge bg-warning text-dark">${row[4]}</span>
                                </c:if>
                                <c:if test="${row[4] == 0}">—</c:if>
                            </td>
                            <td class="text-center">
                                <c:if test="${row[5] > 0}">
                                    <span class="badge bg-success">${row[5]}</span>
                                </c:if>
                                <c:if test="${row[5] == 0}">—</c:if>
                            </td>
                            <td class="text-center">
                                <c:if test="${row[6] > 0}">
                                    <span class="badge bg-danger">${row[6]}</span>
                                </c:if>
                                <c:if test="${row[6] == 0}">—</c:if>
                            </td>
                            <td class="text-center fw-semibold">${row[7]}</td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty empSummary}">
                        <tr><td colspan="7" class="text-center text-muted">No employees found.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<%-- Chart.js --%>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
<script>
(function(){
    var STATUS_COLORS  = ['#ffc107','#198754','#dc3545','#6c757d'];
    var TYPE_COLORS    = ['#0d6efd','#198754','#dc3545','#ffc107','#0dcaf0','#6f42c1','#fd7e14'];
    var MONTH_COLOR    = 'rgba(13,110,253,0.75)';
    var DEPT_COLORS    = ['#0d6efd','#198754','#ffc107','#dc3545','#0dcaf0','#6f42c1'];

    function makeChart(id, type, labels, data, colors, opts) {
        var ctx = document.getElementById(id);
        if (!ctx) return;
        new Chart(ctx, {
            type: type,
            data: {
                labels: labels,
                datasets: [{ data: data, backgroundColor: colors,
                             borderColor: type === 'line' ? colors[0] : undefined,
                             fill: type === 'line', tension: 0.4,
                             label: opts && opts.label ? opts.label : '' }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { position: type === 'bar' || type === 'line' ? 'top' : 'bottom' }
                },
                scales: (type === 'bar' || type === 'line')
                    ? { y: { beginAtZero: true, ticks: { precision: 0 } } }
                    : undefined
            }
        });
    }

    makeChart('statusChart', 'doughnut', ${statusLabelsJson}, ${statusDataJson}, STATUS_COLORS);
    makeChart('typeChart',   'bar',      ${typeLabelsJson},   ${typeDataJson},   TYPE_COLORS,   {label:'Approved'});
    makeChart('deptChart',   'pie',      ${deptLabelsJson},   ${deptDataJson},   DEPT_COLORS);
    makeChart('monthChart',  'bar',      ${monthLabelsJson},  ${monthDataJson},  [MONTH_COLOR], {label:'Approved Leaves'});

    /* Employee table search */
    window.filterEmpTable = function() {
        var q = document.getElementById('empSearch').value.toLowerCase();
        var rows = document.getElementById('empTbody').querySelectorAll('tr');
        rows.forEach(function(r) {
            r.style.display = r.textContent.toLowerCase().includes(q) ? '' : 'none';
        });
    };
})();
</script>
