package com.elms.util;

import jakarta.mail.*;
import jakarta.mail.internet.*;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public final class EmailUtil {

    private EmailUtil() {}

    private static final Properties CONFIG = new Properties();

    static {
        try (InputStream in = EmailUtil.class.getResourceAsStream("/db.properties")) {
            if (in != null) CONFIG.load(in);
        } catch (IOException e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    public static void sendStatusNotification(String to, String subject, String body) {
        String host     = CONFIG.getProperty("mail.smtp.host");
        String port     = CONFIG.getProperty("mail.smtp.port");
        String username = CONFIG.getProperty("mail.smtp.username");
        String password = CONFIG.getProperty("mail.smtp.password");
        String from     = CONFIG.getProperty("mail.from");

        // If mail is not configured, fall back to console log
        if (host == null || username == null || password == null
                || username.isBlank() || password.isBlank()) {
            System.out.printf("ELMS notification to %s: %s%n%s%n", to, subject, body);
            return;
        }

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", port);
        props.put("mail.smtp.ssl.trust", host);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(from));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject);
            message.setContent(body, "text/html; charset=utf-8");
            Transport.send(message);
            System.out.println("Email sent to: " + to);
        } catch (MessagingException e) {
            // Log but don't crash the app if email fails
            System.err.println("Failed to send email to " + to + ": " + e.getMessage());
        }
    }
}