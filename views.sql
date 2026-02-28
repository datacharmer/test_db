-- View: current_salary
CREATE OR REPLACE VIEW current_salary AS
SELECT s.emp_no, s.salary
FROM salaries s
WHERE s.to_date = '9999-01-01';

-- View: employee_department
CREATE OR REPLACE VIEW employee_department AS
SELECT e.emp_no, e.first_name, e.last_name, d.dept_name
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no
WHERE de.to_date = '9999-01-01';
