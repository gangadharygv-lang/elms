package com.elms.util;

public final class EmailUtil {
    private EmailUtil() {
    }

    public static void sendStatusNotification(String to, String subject, String body) {
        // Hook for SMTP integration. The report lists email as a production configuration item.
        System.out.printf("ELMS notification to %s: %s%n%s%n", to, subject, body);
    }
}
