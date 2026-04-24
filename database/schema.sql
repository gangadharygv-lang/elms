CREATE DATABASE IF NOT EXISTS elms_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE elms_db;

DROP TABLE IF EXISTS audit_log;
DROP TABLE IF EXISTS leave_requests;
DROP TABLE IF EXISTS leave_balances;
DROP TABLE IF EXISTS public_holidays;
DROP TABLE IF EXISTS leave_types;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
  dept_id INT NOT NULL AUTO_INCREMENT,
  dept_name VARCHAR(100) NOT NULL,
  hod_user_id INT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (dept_id)
) ENGINE=InnoDB;

CREATE TABLE users (
  user_id INT NOT NULL AUTO_INCREMENT,
  employee_code VARCHAR(20) NOT NULL,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL,
  password_hash VARCHAR(64) NOT NULL,
  role ENUM('EMP','MGR','ADMIN') NOT NULL DEFAULT 'EMP',
  dept_id INT NULL,
  manager_id INT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id),
  UNIQUE KEY uq_emp_code (employee_code),
  UNIQUE KEY uq_email (email),
  FOREIGN KEY (dept_id) REFERENCES departments(dept_id),
  FOREIGN KEY (manager_id) REFERENCES users(user_id)
) ENGINE=InnoDB;

CREATE TABLE leave_types (
  type_id INT NOT NULL AUTO_INCREMENT,
  type_name VARCHAR(50) NOT NULL,
  type_code VARCHAR(10) NOT NULL,
  max_days_per_year INT NOT NULL DEFAULT 0,
  is_paid TINYINT(1) NOT NULL DEFAULT 1,
  carry_forward_allowed TINYINT(1) NOT NULL DEFAULT 0,
  max_carry_forward_days INT NULL,
  requires_attachment TINYINT(1) NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (type_id),
  UNIQUE KEY uq_type_name (type_name),
  UNIQUE KEY uq_type_code (type_code)
) ENGINE=InnoDB;

CREATE TABLE leave_requests (
  request_id INT NOT NULL AUTO_INCREMENT,
  user_id INT NOT NULL,
  leave_type_id INT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  duration_days DECIMAL(4,1) NOT NULL,
  session ENUM('FULL','FIRST_HALF','SECOND_HALF') NOT NULL DEFAULT 'FULL',
  reason TEXT NULL,
  attachment_path VARCHAR(255) NULL,
  status ENUM('PENDING','APPROVED','REJECTED','CANCELLED') NOT NULL DEFAULT 'PENDING',
  approved_by INT NULL,
  manager_remarks TEXT NULL,
  applied_on DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actioned_on DATETIME NULL,
  PRIMARY KEY (request_id),
  INDEX idx_user_status (user_id, status),
  INDEX idx_status_applied (status, applied_on),
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (leave_type_id) REFERENCES leave_types(type_id),
  FOREIGN KEY (approved_by) REFERENCES users(user_id)
) ENGINE=InnoDB;

CREATE TABLE leave_balances (
  balance_id INT NOT NULL AUTO_INCREMENT,
  user_id INT NOT NULL,
  leave_type_id INT NOT NULL,
  year YEAR NOT NULL,
  total_entitled INT NOT NULL DEFAULT 0,
  days_taken DECIMAL(5,1) NOT NULL DEFAULT 0.0,
  days_remaining DECIMAL(5,1) NOT NULL DEFAULT 0.0,
  carried_forward DECIMAL(5,1) NOT NULL DEFAULT 0.0,
  PRIMARY KEY (balance_id),
  UNIQUE KEY uq_balance (user_id, leave_type_id, year),
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (leave_type_id) REFERENCES leave_types(type_id)
) ENGINE=InnoDB;

CREATE TABLE public_holidays (
  holiday_id INT NOT NULL AUTO_INCREMENT,
  holiday_date DATE NOT NULL,
  description VARCHAR(100) NOT NULL,
  is_optional TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (holiday_id),
  UNIQUE KEY uq_holiday_date (holiday_date)
) ENGINE=InnoDB;

CREATE TABLE audit_log (
  log_id INT NOT NULL AUTO_INCREMENT,
  entity_type VARCHAR(50) NOT NULL,
  entity_id INT NOT NULL,
  action VARCHAR(50) NOT NULL,
  performed_by INT NOT NULL,
  old_value TEXT NULL,
  new_value TEXT NULL,
  ip_address VARCHAR(45) NULL,
  logged_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (log_id),
  FOREIGN KEY (performed_by) REFERENCES users(user_id)
) ENGINE=InnoDB;

INSERT INTO departments (dept_name) VALUES
  ('Human Resources'),
  ('Engineering'),
  ('Finance'),
  ('Marketing');

INSERT INTO leave_types (type_name, type_code, max_days_per_year, is_paid,
  carry_forward_allowed, max_carry_forward_days, requires_attachment) VALUES
  ('Casual Leave', 'CL', 12, 1, 0, 0, 0),
  ('Earned Leave', 'EL', 15, 1, 1, 10, 0),
  ('Medical Leave', 'ML', 7, 1, 0, 0, 1),
  ('Maternity Leave', 'MAT', 90, 1, 0, 0, 1),
  ('Paternity Leave', 'PAT', 15, 1, 0, 0, 0),
  ('Compensatory Off', 'CO', 0, 1, 1, 5, 0),
  ('Loss of Pay', 'LOP', 0, 0, 0, 0, 0);

INSERT INTO users (employee_code, full_name, email, password_hash, role, dept_id, manager_id) VALUES
  ('ADM001', 'System Administrator', 'admin@elms.local', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'ADMIN', 1, NULL),
  ('MGR001', 'Priya Sharma', 'manager@elms.local', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'MGR', 2, NULL),
  ('EMP001', 'Arjun Rao', 'employee@elms.local', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'EMP', 2, 2);

UPDATE departments SET hod_user_id = 1 WHERE dept_id = 1;
UPDATE departments SET hod_user_id = 2 WHERE dept_id = 2;

INSERT INTO leave_balances (user_id, leave_type_id, year, total_entitled, days_remaining)
SELECT u.user_id, lt.type_id, YEAR(CURDATE()), lt.max_days_per_year, lt.max_days_per_year
FROM users u
CROSS JOIN leave_types lt
WHERE u.role IN ('EMP','MGR');

CREATE TABLE IF NOT EXISTS password_reset_tokens (
  token_id   INT          NOT NULL AUTO_INCREMENT,
  user_id    INT          NOT NULL,
  token      VARCHAR(64)  NOT NULL,
  expires_at DATETIME     NOT NULL,
  used       TINYINT(1)   NOT NULL DEFAULT 0,
  PRIMARY KEY (token_id),
  UNIQUE KEY uq_token (token),
  FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB;

INSERT INTO public_holidays (holiday_date, description, is_optional) VALUES
  ('2026-01-26', 'Republic Day', 0),
  ('2026-08-15', 'Independence Day', 0),
  ('2026-10-02', 'Gandhi Jayanti', 0),
  ('2026-12-25', 'Christmas', 0);