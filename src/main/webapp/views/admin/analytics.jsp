<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<h2 class="mb-4">Analytics Dashboard</h2>

<div class="row g-4">
    <div class="col-md-6">
        <div class="card p-3 shadow-sm">
            <h6 class="mb-3">Status Distribution</h6>
            <canvas id="statusChart"></canvas>
        </div>
    </div>
    <div class="col-md-6">
        <div class="card p-3 shadow-sm">
            <h6 class="mb-3">Leave Type Distribution</h6>
            <canvas id="typeChart"></canvas>
        </div>
    </div>
</div>

<hr class="my-4">

<h5 class="mb-3">Recent Requests</h5>
<div class="table-responsive">
    <table class="table table-striped table-bordered align-middle">
        <thead class="table-dark">
            <tr>
                <th>Employee</th>
                <th>Type</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="r" items="${recentRequests}">
                <tr>
                    <td>${r.employeeName}</td>
                    <td>${r.leaveTypeCode}</td>
                    <td>
                        <span class="badge
                            ${r.status == 'APPROVED' ? 'bg-success' :
                              r.status == 'REJECTED' ? 'bg-danger' :
                              'bg-warning text-dark'}">
                            ${r.status}
                        </span>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>

<%-- Chart.js CDN --%>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    // FIX: original Chart.js blocks were missing closing }); on both new Chart() calls.
    // Status pie chart
    const statusCtx = document.getElementById('statusChart');
    new Chart(statusCtx, {
        type: 'pie',
        data: {
            labels: ${statusLabelsJson},
            datasets: [{
                data: ${statusDataJson},
                backgroundColor: ['#198754', '#dc3545', '#ffc107']
            }]
        },
        options: {
            responsive: true,
            plugins: { legend: { position: 'bottom' } }
        }
    });

    // Leave-type bar chart
    const typeCtx = document.getElementById('typeChart');
    new Chart(typeCtx, {
        type: 'bar',
        data: {
            labels: ${typeLabelsJson},
            datasets: [{
                label: 'Leaves',
                data: ${typeDataJson},
                backgroundColor: '#0d6efd'
            }]
        },
        options: {
            responsive: true,
            scales: { y: { beginAtZero: true } }
        }
    });
</script>
