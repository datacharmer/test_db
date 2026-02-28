# Employees Database Schema Overview

## Tables

### employees
- emp_no (INT, PK)
- birth_date (DATE)
- first_name (VARCHAR)
- last_name (VARCHAR)
- gender (ENUM)
- hire_date (DATE)

### departments
- dept_no (CHAR, PK)
- dept_name (VARCHAR)

### salaries
- emp_no (INT, FK)
- salary (INT)
- from_date (DATE)
- to_date (DATE)

### titles
- emp_no (INT, FK)
- title (VARCHAR)
- from_date (DATE)
- to_date (DATE)

### dept_emp
- emp_no (INT, FK)
- dept_no (CHAR, FK)
- from_date (DATE)
- to_date (DATE)

### dept_manager
- emp_no (INT, FK)
- dept_no (CHAR, FK)
- from_date (DATE)
- to_date (DATE)
