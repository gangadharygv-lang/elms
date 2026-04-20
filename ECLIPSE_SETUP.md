# Eclipse Setup for ELMS

Use this when Eclipse shows red error markers after importing the project.

## Correct Runtime

This project is written for the report stack:

- Java 11 source level
- Apache Tomcat 10.1.x
- Jakarta Servlet/JSP
- MySQL 8
- Maven

Do not run it on Tomcat 9 because Tomcat 9 uses `javax.servlet`, while this code uses `jakarta.servlet`.

Tomcat 11 can also cause facet/runtime warnings in Eclipse because it expects newer Jakarta versions. For this project, install and select Tomcat 10.1.x.

## Eclipse Import Steps

1. Install **Eclipse IDE for Enterprise Java and Web Developers**.
2. Install **Apache Tomcat 10.1.x**.
3. In Eclipse, go to **Window > Preferences > Server > Runtime Environments**.
4. Add **Apache Tomcat v10.1** and select your Tomcat folder.
5. Import project using **File > Import > Maven > Existing Maven Projects**.
6. Right-click project > **Maven > Update Project**.
7. Right-click project > **Properties > Targeted Runtimes**.
8. Select **Apache Tomcat v10.1**.
9. Right-click project > **Properties > Project Facets** and confirm:
   - Java: 11
   - Dynamic Web Module: 6.0

## Database Setup

Run:

```sql
SOURCE database/schema.sql;
```

Then edit:

```text
src/main/resources/db.properties
```

Set your MySQL username and password.

## Demo Accounts

Password for all demo accounts:

```text
password123
```

| Role | Email |
| --- | --- |
| Admin | admin@elms.local |
| Manager | manager@elms.local |
| Employee | employee@elms.local |

## Common Errors

### `jakarta.servlet cannot be resolved`

Cause: Maven dependencies are not downloaded or no Tomcat 10 runtime is selected.

Fix:

- Right-click project > **Maven > Update Project**
- Select **Force Update of Snapshots/Releases**
- Select Tomcat 10.1 in **Targeted Runtimes**

### `javax.servlet` expected or servlet classes missing

Cause: Tomcat 9 is selected.

Fix: Use Tomcat 10.1, not Tomcat 9.

### Dynamic Web Module facet error

Cause: Eclipse attached the project to the wrong Tomcat runtime.

Fix:

- Project > Properties > Targeted Runtimes
- Uncheck wrong runtime
- Check Apache Tomcat v10.1
- Maven > Update Project

### MySQL login or connection error

Cause: `db.properties` still has placeholder credentials.

Fix: update:

```properties
db.username=root
db.password=your_mysql_password
```
