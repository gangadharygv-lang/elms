<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ELMS Analytics</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
<jsp:include page="partials-nav.jsp"/>
<main class="page">
  <section class="page-title">
    <h1>Analytics</h1>
    <p>Leave utilization by status, type, department, and month.</p>
  </section>

  <div class="chart-grid">
    <section class="panel chart-panel">
      <h2>Status</h2>
      <canvas id="statusChart"></canvas>
    </section>
    <section class="panel chart-panel">
      <h2>Leave Type</h2>
      <canvas id="typeChart"></canvas>
    </section>
    <section class="panel chart-panel">
      <h2>Department</h2>
      <canvas id="departmentChart"></canvas>
    </section>
    <section class="panel chart-panel">
      <h2>Monthly Trend</h2>
      <canvas id="monthlyChart"></canvas>
    </section>
  </div>

  <h2>Recent Activity</h2>
  <table>
    <thead>
      <tr><th>Employee</th><th>Type</th><th>Dates</th><th>Status</th></tr>
    </thead>
    <tbody>
      <c:forEach var="r" items="${recentRequests}">
        <tr>
          <td>${r.employeeName}</td>
          <td>${r.leaveTypeCode}</td>
          <td>${r.startDate} to ${r.endDate}</td>
          <td><span class="status ${r.status}">${r.status}</span></td>
        </tr>
      </c:forEach>
    </tbody>
  </table>
</main>
<script>
const palette = ["#16745f", "#d1495b", "#edae49", "#3066be", "#6a994e", "#8d5a97", "#4d908e"];

function renderChart(id, type, labels, data, label) {
  const canvas = document.getElementById(id);
  if (!canvas) return;
  new Chart(canvas, {
    type: type,
    data: {
      labels: labels,
      datasets: [{
        label: label,
        data: data,
        backgroundColor: palette,
        borderColor: "#17202a",
        borderWidth: type === "line" ? 2 : 1,
        tension: 0.25,
        fill: type === "line"
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: { legend: { display: type !== "bar" } },
      scales: type === "pie" || type === "doughnut" ? {} : {
        y: { beginAtZero: true, ticks: { precision: 0 } }
      }
    }
  });
}

renderChart("statusChart", "doughnut", ${statusLabelsJson}, ${statusDataJson}, "Requests");
renderChart("typeChart", "pie", ${typeLabelsJson}, ${typeDataJson}, "Approved Leaves");
renderChart("departmentChart", "bar", ${departmentLabelsJson}, ${departmentDataJson}, "Approved Leaves");
renderChart("monthlyChart", "line", ${monthlyLabelsJson}, ${monthlyDataJson}, "Approved Leaves");
</script>
</body>
</html>
