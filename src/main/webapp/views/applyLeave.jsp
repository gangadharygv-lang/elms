<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.elms.model.LeaveType" %>
<%!
  private String h(Object value) {
    if (value == null) return "";
    return value.toString()
        .replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace("\"", "&quot;")
        .replace("'", "&#39;");
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Apply Leave</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
<jsp:include page="partials-nav.jsp"/>
<main class="page narrow">
  <section class="page-title">
    <h1>Apply for Leave</h1>
    <p>Choose the leave type, dates, and session.</p>
  </section>

  <%
    String error = request.getParameter("error");
    if (error != null && !error.isBlank()) {
  %>
    <div class="alert error"><%= h(error) %></div>
  <%
    }
  %>

  <form class="panel" method="post" action="<%= request.getContextPath() %>/leave/apply" enctype="multipart/form-data">
    <label>Leave Type</label>
    <select name="leaveTypeId" id="leaveTypeId" required onchange="updateBalance()">
      <option value="">Select leave type</option>
      <%
        List<LeaveType> leaveTypes = (List<LeaveType>) request.getAttribute("leaveTypes");
        if (leaveTypes != null) {
          for (LeaveType lt : leaveTypes) {
      %>
        <option value="<%= lt.getTypeId() %>" data-balance="<%= h(lt.getBalanceRemaining()) %>" data-attachment="<%= lt.isRequiresAttachment() %>">
          <%= h(lt.getTypeName()) %> (<%= h(lt.getTypeCode()) %>)
        </option>
      <%
          }
        }
      %>
    </select>
    <span class="hint" id="balanceHint"></span>

    <div class="grid-2">
      <div>
        <label>From Date</label>
        <input type="date" name="startDate" id="startDate" required onchange="calcDuration()">
      </div>
      <div>
        <label>To Date</label>
        <input type="date" name="endDate" id="endDate" required onchange="calcDuration()">
      </div>
    </div>

    <label>Session</label>
    <select name="session" id="session" onchange="calcDuration()">
      <option value="FULL">Full day</option>
      <option value="FIRST_HALF">First half</option>
      <option value="SECOND_HALF">Second half</option>
    </select>

    <div class="duration" id="durationBanner">Duration will appear after selecting dates.</div>

    <label>Reason</label>
    <textarea name="reason" rows="4" maxlength="500"></textarea>

    <label>Supporting Document</label>
    <input type="file" name="attachment" accept=".pdf,.jpg,.jpeg">

    <button type="submit">Submit Request</button>
  </form>
</main>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>
