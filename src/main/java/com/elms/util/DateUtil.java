package com.elms.util;

import java.math.BigDecimal;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Set;

public final class DateUtil {
    private static final DateTimeFormatter DISPLAY = DateTimeFormatter.ofPattern("dd-MMM-yyyy");

    private DateUtil() {
    }

    public static BigDecimal calculateWorkingDays(LocalDate start, LocalDate end, String session,
                                                  Set<LocalDate> holidays) {
        if (!"FULL".equals(session)) {
            return new BigDecimal("0.5");
        }
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
