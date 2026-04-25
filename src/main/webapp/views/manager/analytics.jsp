<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<h2 class="mb-1">Team Analytics</h2>
<p class="text-muted mb-4">Leave intelligence for your direct reportees &mdash; <strong>${sessionScope.user.fullName}</strong></p>

<%-- ══════════════════════════════════════════════════════════
     KPI CARDS
═══════════════════════════════════════════════════════════ --%>
<div class="row g-3 mb-4">
    <div class="col-6 col-md-4 col-xl-2">
        <div class="card text-center border-0 shadow-sm h-100" style="background:#e8f5e9;">
            <div class="card-body py-3">
                <div class="fs-2 fw-bold text-success">${kpi.teamSize}</div>
                <div class="small text-muted">Team Size</div>
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
                <div class="fs-2 fw-bold" style="color:#7b1fa2;">${kpi.totalDaysTaken}</div>
                <div class="small text-muted">Days Taken</div>
            </div>
        </div>
    </div>
</div>

<%-- ══════════════════════════════════════════════════════════
     CHARTS
═══════════════════════════════════════════════════════════ --%>
<div class="row g-4 mb-4">
    <div class="col-md-4">
        <div class="card shadow-sm h-100">
            <div class="card-header fw-semibold bg-white border-bottom">Status Distribution</div>
            <div class="card-body d-flex align-items-center justify-content-center">
                <canvas id="statusChart" style="max-height:250px;"></canvas>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card shadow-sm h-100">
            <div class="card-header fw-semibold bg-white border-bottom">Approved Leaves by Type</div>
            <div class="card-body d-flex align-items-center justify-content-center">
                <canvas id="typeChart" style="max-height:250px;"></canvas>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card shadow-sm h-100">
            <div class="card-header fw-semibold bg-white border-bottom">Monthly Approved Trend</div>
            <div class="card-body d-flex align-items-center justify-content-center">
                <canvas id="monthChart" style="max-height:250px;"></canvas>
            </div>
        </div>
    </div>
</div>

<%-- ══════════════════════════════════════════════════════════
     TEAM SUMMARY TABLE
═══════════════════════════════════════════════════════════ --%>
<div class="card shadow-sm mb-4">
    <div class="card-header fw-semibold bg-white border-bottom">
        Team Leave Summary
    </div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-bordered table-striped align-middle mb-0">
                <thead class="table-dark">
                    <tr>
                        <th>Name</th>
                        <th>Code</th>
                        <th class="text-center">Pending</th>
                        <th class="text-center">Approved</th>
                        <th class="text-center">Rejected</th>
                        <th class="text-center">Days Taken</th>
                        <th style="min-width:140px;">Activity</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="row" items="${teamSummary}">
                        <c:set var="total" value="${row[2] + row[3] + row[4]}"/>
                        <tr>
                            <td>${row[0]}</td>
                            <td><code>${row[1]}</code></td>
                            <td class="text-center">
                                <c:if test="${row[2] > 0}">
                                    <span class="badge bg-warning text-dark">${row[2]}</span>
                                </c:if>
                                <c:if test="${row[2] == 0}">—</c:if>
                            </td>
                            <td class="text-center">
                                <c:if test="${row[3] > 0}">
                                    <span class="badge bg-success">${row[3]}</span>
                                </c:if>
                                <c:if test="${row[3] == 0}">—</c:if>
                            </td>
                            <td class="text-center">
                                <c:if test="${row[4] > 0}">
                                    <span class="badge bg-danger">${row[4]}</span>
                                </c:if>
                                <c:if test="${row[4] == 0}">—</c:if>
                            </td>
                            <td class="text-center fw-semibold">${row[5]}</td>
                            <td>
                                <c:if test="${total > 0}">
                                    <div class="progress" style="height:8px;" title="${total} total requests">
                                        <div class="progress-bar bg-success"
                                             style="width:${row[3] * 100 / total}%"
                                             title="Approved"></div>
                                        <div class="progress-bar bg-warning"
                                             style="width:${row[2] * 100 / total}%"
                                             title="Pending"></div>
                                        <div class="progress-bar bg-danger"
                                             style="width:${row[4] * 100 / total}%"
                                             title="Rejected"></div>
                                    </div>
                                    <small class="text-muted">${total} request(s)</small>
                                </c:if>
                                <c:if test="${total == 0}">
                                    <span class="text-muted small">No requests</span>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty teamSummary}">
                        <tr>
                            <td colspan="7" class="text-center text-muted py-3">
                                No employees assigned to you yet.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
<script>
(function(){
    var STATUS_COLORS = ['#ffc107','#198754','#dc3545','#6c757d'];
    var TYPE_COLORS   = ['#0d6efd','#198754','#dc3545','#ffc107','#0dcaf0','#6f42c1','#fd7e14'];

    function bar(id, labels, data, color, label) {
        var ctx = document.getElementById(id);
        if (!ctx) return;
        new Chart(ctx, {
            type: 'bar',
            data: { labels: labels,
                    datasets: [{ label: label, data: data,
                                 backgroundColor: color }] },
            options: { responsive: true,
                       plugins: { legend: { position: 'top' } },
                       scales: { y: { beginAtZero: true, ticks: { precision: 0 } } } }
        });
    }
    function doughnut(id, labels, data, colors) {
        var ctx = document.getElementById(id);
        if (!ctx) return;
        new Chart(ctx, {
            type: 'doughnut',
            data: { labels: labels,
                    datasets: [{ data: data, backgroundColor: colors }] },
            options: { responsive: true, plugins: { legend: { position: 'bottom' } } }
        });
    }

    doughnut('statusChart', ${statusLabelsJson}, ${statusDataJson}, STATUS_COLORS);
    bar('typeChart',        ${typeLabelsJson},   ${typeDataJson},   TYPE_COLORS,             'Approved');
    bar('monthChart',       ${monthLabelsJson},  ${monthDataJson},  'rgba(13,110,253,0.75)', 'Approved Leaves');
})();
</script>
