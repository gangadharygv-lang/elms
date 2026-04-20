# Enterprise Leave Management System

Java EE web application based on `ELMS_Final_Project_Report.pdf`.

## Stack

- Java 11 source level
- Jakarta Servlet/JSP on Apache Tomcat 10.x
- JDBC with MySQL 8
- Maven WAR packaging
- JSP/JSTL views with role-based navigation

## Implemented Modules

- Login/logout with SHA-256 password hashing
- Employee dashboard with leave balances and request history
- Leave application with date validation, overlap checks, holidays, half-day handling, and optional attachment upload
- Pending request cancellation
- Manager approval/rejection with mandatory remarks
- ACID transaction for approval and leave-balance deduction
- Admin/manager analytics by status, leave type, department, and month
- Admin user creation
- MySQL schema and seed data

## Setup

1. Create the database:

   ```sql
   SOURCE database/schema.sql;
   ```

2. Update database credentials in:

   ```text
   src/main/resources/db.properties
   ```

3. Build the WAR:

   ```bash
   mvn clean package
   ```

4. Deploy:

   Copy `target/elms.war` to Tomcat 10 `webapps`, then open:

   ```text
   http://localhost:8080/elms
   ```

## Demo Logins

All demo accounts use the password:

```text
password123
```

| Role | Email |
| --- | --- |
| Admin | admin@elms.local |
| Manager | manager@elms.local |
| Employee | employee@elms.local |

## Notes

- `db.properties` uses `change_me` as a placeholder password.
- Maven is not bundled in this workspace, so build from a machine where Maven is installed.
- The report lists PDF/Excel export and scheduled email reports; this scaffold keeps the core analytics screen and includes an `EmailUtil` hook for SMTP integration.
