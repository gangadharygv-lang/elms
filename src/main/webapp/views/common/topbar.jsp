<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<nav class="navbar navbar-dark bg-success px-4">
    <span class="navbar-brand fw-bold">ELMS</span>

    <%-- Live date & time — centre of topbar --%>
    <div id="elms-clock" class="d-flex flex-column align-items-center lh-1">
        <span id="clock-time" class="fw-bold" style="font-size:1.1rem;letter-spacing:.05em;"></span>
        <span id="clock-date" class="opacity-75" style="font-size:.75rem;"></span>
    </div>

    <div class="d-flex align-items-center gap-3 text-white">
        <%-- Role badge --%>
        <span class="badge bg-white text-success fw-semibold"
              style="font-size:.7rem;letter-spacing:.04em;">
            ${sessionScope.user.role}
        </span>
        <span>${sessionScope.user.fullName}</span>
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-light btn-sm">
            Logout
        </a>
    </div>
</nav>

<style>
    #elms-clock { color:#fff; min-width:140px; text-align:center; }

    @keyframes tickPulse {
        0%   { opacity:1;  }
        50%  { opacity:.55;}
        100% { opacity:1;  }
    }
    #clock-time.tick { animation: tickPulse .3s ease; }
</style>

<script>
(function () {
    const DAYS   = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
    const MONTHS = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];

    function pad(n) { return String(n).padStart(2, '0'); }

    function tick() {
        const now  = new Date();
        const h    = now.getHours();
        const ampm = h >= 12 ? 'PM' : 'AM';
        const h12  = h % 12 || 12;

        const timeEl = document.getElementById('clock-time');
        const dateEl = document.getElementById('clock-date');

        timeEl.textContent = pad(h12) + ':' + pad(now.getMinutes()) + ':' +
                             pad(now.getSeconds()) + '\u00a0' + ampm;

        dateEl.textContent = DAYS[now.getDay()] + ',\u00a0' +
                             pad(now.getDate()) + '\u00a0' +
                             MONTHS[now.getMonth()] + '\u00a0' +
                             now.getFullYear();

        // Brief pulse every second
        timeEl.classList.remove('tick');
        void timeEl.offsetWidth;   // force reflow to restart animation
        timeEl.classList.add('tick');
    }

    tick();                  // fire immediately — no blank flash on load
    setInterval(tick, 1000);
})();
</script>
