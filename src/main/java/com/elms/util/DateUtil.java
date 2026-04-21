package com.elms.util;

import java.math.BigDecimal;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Set;

public final class DateUtil {

    private static final DateTimeFormatter DISPLAY = DateTimeFormatter.ofPattern("dd-MMM-yyyy");

    private DateUtil() {}

    /**
     * Calculate working days for a leave request.
     *
     * FIX: original check was (!\"FULL\".equals(session)) which returned 0.5 for ANY
     * non-FULL value including unknown strings. But the Session enum values are
     * FULL, FIRST_HALF, SECOND_HALF — not "HALF". So submitting FIRST_HALF or
     * SECOND_HALF from the old form sent "HALF" → not equal to "FULL" → returned 0.5
     * correctly by accident. After fixing the form to send "FIRST_HALF"/"SECOND_HALF",
     * the old (!FULL) check still works, but it's fragile and unclear.
     * Now explicitly handling each known session value.
     */
    public static BigDecimal calculateWorkingDays(LocalDate start, LocalDate end,
                                                   String session, Set<LocalDate> holidays) {
        // Half-day sessions are always exactly 0.5 days (single day enforced by servlet)
        if ("FIRST_HALF".equals(session) || "SECOND_HALF".equals(session)) {
            return new BigDecimal("0.5");
        }

        // FULL: count working days excluding weekends and holidays
        long count = start.datesUntil(end.plusDays(1))
                .filter(date -> !isWeekend(date))
                .filter(date -> holidays == null || !holidays.contains(date))
                .count();
        return BigDecimal.valueOf(count);
    }

    public static boolean isWeekend(LocalDate date) {
        DayOfWeek day = date.getDayOfWeek();
        return day == DayOfWeek.SATURDAY || day == DayOfWeek.SUNDAY;
    }

    public static String format(LocalDate date) {
        return date == null ? "-" : date.format(DISPLAY);
    }
}
