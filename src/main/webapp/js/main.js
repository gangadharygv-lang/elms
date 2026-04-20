function updateBalance() {
  const select = document.getElementById("leaveTypeId");
  const option = select.options[select.selectedIndex];
  const hint = document.getElementById("balanceHint");
  if (!option || !option.value) {
    hint.textContent = "";
    return;
  }
  const balance = option.dataset.balance || "0";
  const attachment = option.dataset.attachment === "true" ? " Document required." : "";
  hint.textContent = `Available balance: ${balance} day(s).${attachment}`;
}

function calcDuration() {
  const startValue = document.getElementById("startDate").value;
  const endValue = document.getElementById("endDate").value;
  const session = document.getElementById("session").value;
  const banner = document.getElementById("durationBanner");
  if (!startValue || !endValue) {
    return;
  }
  const start = new Date(startValue);
  const end = new Date(endValue);
  if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime()) || end < start) {
    banner.textContent = "Select a valid date range.";
    return;
  }
  if (session !== "FULL") {
    banner.textContent = "Approximate duration: 0.5 day. Server will validate the final value.";
    return;
  }
  const diff = Math.round((end - start) / 86400000) + 1;
  banner.textContent = `Approximate duration: ${diff} day(s). Weekends and holidays are excluded on submit.`;
}
