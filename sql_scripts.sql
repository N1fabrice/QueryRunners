
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE employees';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

-- Create the employees table
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE
);


-- Insert sample data
INSERT ALL
    INTO Employees (employee_id, first_name, last_name, department, salary, hire_date) VALUES (1, 'John', 'Smith', 'IT', 75000.00, TO_DATE('2018-06-20', 'YYYY-MM-DD'))
    INTO Employees (employee_id, first_name, last_name, department, salary, hire_date) VALUES (2, 'Sarah', 'Jones', 'HR', 85000.00, TO_DATE('2015-03-14', 'YYYY-MM-DD'))
    INTO Employees (employee_id, first_name, last_name, department, salary, hire_date) VALUES (3, 'Michael', 'Brown', 'Finance', 95000.00, TO_DATE('2010-08-24', 'YYYY-MM-DD'))
    INTO Employees (employee_id, first_name, last_name, department, salary, hire_date) VALUES (4, 'Emily', 'Wilson', 'IT', 72000.00, TO_DATE('2020-01-10', 'YYYY-MM-DD'))
    INTO Employees (employee_id, first_name, last_name, department, salary, hire_date) VALUES (5, 'David', 'Miller', 'Marketing', 67000.00, TO_DATE('2019-11-15', 'YYYY-MM-DD'))
    INTO Employees (employee_id, first_name, last_name, department, salary, hire_date) VALUES (6, 'Jessica', 'Davis', 'HR', 82000.00, TO_DATE('2016-05-30', 'YYYY-MM-DD'))
    INTO Employees (employee_id, first_name, last_name, department, salary, hire_date) VALUES (7, 'Robert', 'Taylor', 'Finance', 92000.00, TO_DATE('2012-04-22', 'YYYY-MM-DD'))
    INTO Employees (employee_id, first_name, last_name, department, salary, hire_date) VALUES (8, 'Amanda', 'Anderson', 'Marketing', 71000.00, TO_DATE('2021-02-08', 'YYYY-MM-DD'))
    INTO Employees (employee_id, first_name, last_name, department, salary, hire_date) VALUES (9, 'Thomas', 'Johnson', 'IT', 78000.00, TO_DATE('2017-09-18', 'YYYY-MM-DD'))
    INTO Employees (employee_id, first_name, last_name, department, salary, hire_date) VALUES (10, 'Lisa', 'Clark', 'Finance', 88000.00, TO_DATE('2014-07-12', 'YYYY-MM-DD'))
SELECT * FROM dual;

COMMIT;

-- 1. ROW_NUMBER() Examples
-- Example 1a: Assign row numbers to employees overall
SELECT 
    employee_id,
    first_name,
    last_name,
    department,
    salary,
    ROW_NUMBER() OVER(ORDER BY salary DESC) as overall_salary_rank
FROM 
    employees;

-- Example 1b: Assign row numbers within each department
SELECT 
    employee_id,
    first_name,
    last_name,
    department,
    salary,
    ROW_NUMBER() OVER(PARTITION BY department ORDER BY salary DESC) as dept_salary_rank
FROM 
    employees;

-- 2. RANK() and DENSE_RANK() Examples
-- Example 2a: Compare RANK() vs DENSE_RANK()
SELECT 
    employee_id,
    first_name,
    last_name,
    department,
    salary,
    RANK() OVER(ORDER BY salary DESC) as salary_rank,
    DENSE_RANK() OVER(ORDER BY salary DESC) as dense_salary_rank
FROM 
    employees;

-- Example 2b: RANK() and DENSE_RANK() within departments
SELECT 
    employee_id,
    first_name,
    last_name,
    department,
    salary,
    RANK() OVER(PARTITION BY department ORDER BY salary DESC) as dept_salary_rank,
    DENSE_RANK() OVER(PARTITION BY department ORDER BY salary DESC) as dept_dense_salary_rank
FROM 
    employees;

-- 3. LAG() and LEAD() Examples
-- Example 3a: Compare current salary with previous employee's salary
SELECT 
    employee_id,
    first_name,
    last_name,
    department,
    salary,
    LAG(salary, 1, 0) OVER(ORDER BY employee_id) as previous_salary,
    salary - LAG(salary, 1, 0) OVER(ORDER BY employee_id) as salary_difference
FROM 
    employees;

-- Example 3b: Compare salary with next highest earner in the same department
SELECT 
    employee_id,
    first_name,
    last_name,
    department,
    salary,
    LEAD(salary, 1, NULL) OVER(PARTITION BY department ORDER BY salary DESC) as next_lower_salary,
    salary - LEAD(salary, 1, 0) OVER(PARTITION BY department ORDER BY salary DESC) as salary_gap
FROM 
    employees;

-- Example 3c: Calculate year-over-year experience (days between hire dates)
SELECT 
    employee_id,
    first_name,
    last_name,
    department,
    hire_date,
    LAG(hire_date, 1) OVER(PARTITION BY department ORDER BY hire_date) as prev_hire_date,
    hire_date - LAG(hire_date, 1) OVER(PARTITION BY department ORDER BY hire_date) as days_after_prev_hire
FROM 
    employees;

-- 4. Aggregate Window Functions
-- Example 4a: Calculate running total of salaries
SELECT 
    employee_id,
    first_name,
    last_name,
    department,
    salary,
    SUM(salary) OVER(ORDER BY employee_id) as running_total_salary
FROM 
    employees;

-- Example 4b: Calculate department statistics
SELECT 
    employee_id,
    first_name,
    last_name,
    department,
    salary,
    AVG(salary) OVER(PARTITION BY department) as dept_avg_salary,
    MAX(salary) OVER(PARTITION BY department) as dept_max_salary,
    MIN(salary) OVER(PARTITION BY department) as dept_min_salary,
    COUNT(*) OVER(PARTITION BY department) as dept_employee_count
FROM 
    employees;

-- Example 4c: Calculate percentage of total department salary
SELECT 
    employee_id,
    first_name,
    last_name,
    department,
    salary,
    ROUND(salary / SUM(salary) OVER(PARTITION BY department) * 100, 2) as pct_of_dept_salary
FROM 
    employees;

-- Example 4d: Calculate running averages
SELECT 
    employee_id,
    first_name,
    last_name,
    department,
    hire_date,
    salary,
    AVG(salary) OVER(PARTITION BY department ORDER BY hire_date 
                     ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as moving_avg_salary
FROM 
    employees;

-- 5. Percentile functions
-- Example 5a: Calculate salary percentiles across the company
SELECT 
    employee_id,
    first_name,
    last_name,
    department,
    salary,
    PERCENT_RANK() OVER(ORDER BY salary) * 100 as salary_percentile,
    NTILE(4) OVER(ORDER BY salary) as salary_quartile
FROM 
    employees;

-- 6. First_value and last_value
-- Example 6a: Compare each employee's salary with the highest in their department
SELECT 
    employee_id,
    first_name,
    last_name,
    department,
    salary,
    FIRST_VALUE(salary) OVER(PARTITION BY department ORDER BY salary DESC
                             ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as highest_dept_salary,
    salary - FIRST_VALUE(salary) OVER(PARTITION BY department ORDER BY salary DESC
                             ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as salary_gap_from_highest
FROM 
    employees;

-- 7. Practical example: Identify employees earning above department average
SELECT 
    employee_id,
    first_name,
    last_name,
    department,
    salary,
    AVG(salary) OVER(PARTITION BY department) as dept_avg_salary,
    CASE 
        WHEN salary > AVG(salary) OVER(PARTITION BY department) THEN 'Above Average'
        WHEN salary = AVG(salary) OVER(PARTITION BY department) THEN 'Average'
        ELSE 'Below Average'
    END as salary_status
FROM 
    employees
ORDER BY 
    department, salary DESC;




-- 1. Compare Values with Previous or Next Records with HIGHER/LOWER/EQUAL display
-- Display whether salary is HIGHER, LOWER, or EQUAL compared to previous record
SELECT 
    employee_id,
    first_name,
    last_name,
    department,
    salary,
    LAG(salary) OVER(ORDER BY employee_id) as previous_salary,
    CASE 
        WHEN salary > LAG(salary) OVER(ORDER BY employee_id) THEN 'HIGHER'
        WHEN salary < LAG(salary) OVER(ORDER BY employee_id) THEN 'LOWER'
        WHEN salary = LAG(salary) OVER(ORDER BY employee_id) THEN 'EQUAL'
        ELSE 'FIRST RECORD' -- For the first record with no previous value
    END AS compared_to_previous,
    LEAD(salary) OVER(ORDER BY employee_id) as next_salary,
    CASE 
        WHEN salary > LEAD(salary) OVER(ORDER BY employee_id) THEN 'HIGHER'
        WHEN salary < LEAD(salary) OVER(ORDER BY employee_id) THEN 'LOWER'
        WHEN salary = LEAD(salary) OVER(ORDER BY employee_id) THEN 'EQUAL'
        ELSE 'LAST RECORD' -- For the last record with no next value
    END AS compared_to_next
FROM 
    employees
ORDER BY 
    employee_id;

-- 2. Explanation of the difference between RANK() and DENSE_RANK()
-- This query builds on the existing Example 2b from your script
-- It adds a column to highlight ranks where differences would be visible
SELECT 
    employee_id,
    first_name,
    last_name,
    department,
    salary,
    RANK() OVER(PARTITION BY department ORDER BY salary DESC) as dept_salary_rank,
    DENSE_RANK() OVER(PARTITION BY department ORDER BY salary DESC) as dept_dense_salary_rank,
    CASE 
        WHEN RANK() OVER(PARTITION BY department ORDER BY salary DESC) != 
             DENSE_RANK() OVER(PARTITION BY department ORDER BY salary DESC) 
        THEN 'Shows difference: RANK leaves gaps after ties, DENSE_RANK does not'
        ELSE NULL
    END as rank_difference_explained
FROM 
    employees
ORDER BY
    department,
    salary DESC;

-- 3. Identifying Top 3 Records from each department
WITH ranked_employees AS (
    SELECT 
        employee_id,
        first_name,
        last_name,
        department,
        salary,
        DENSE_RANK() OVER(PARTITION BY department ORDER BY salary DESC) as salary_rank
    FROM 
        employees
)
SELECT 
    employee_id,
    first_name,
    last_name,
    department,
    salary,
    salary_rank
FROM 
    ranked_employees
WHERE 
    salary_rank <= 3
ORDER BY 
    department, 
    salary_rank;

-- 4. Finding the Earliest 2 Records (first 2 employees to join each department)
WITH ranked_by_hire_date AS (
    SELECT 
        employee_id,
        first_name,
        last_name,
        department,
        hire_date,
        ROW_NUMBER() OVER(PARTITION BY department ORDER BY hire_date ASC) as hire_date_rank
    FROM 
        employees
)
SELECT 
    employee_id,
    first_name,
    last_name,
    department,
    hire_date,
    hire_date_rank,
    'This query finds the first 2 employees to join each department based on hire date' as explanation
FROM 
    ranked_by_hire_date
WHERE 
    hire_date_rank <= 2
ORDER BY 
    department, 
    hire_date;

-- 5. Aggregation with Window Functions - Department vs Overall Maximum
SELECT 
    employee_id,
    first_name,
    last_name,
    department,
    salary,
    -- Maximum salary within the employee's department (category level)
    MAX(salary) OVER(PARTITION BY department) as dept_max_salary,
    -- Maximum salary across all departments (overall)
    MAX(salary) OVER() as overall_max_salary,
    -- Percentage comparisons
    ROUND((salary / MAX(salary) OVER(PARTITION BY department)) * 100, 2) as pct_of_dept_max,
    ROUND((salary / MAX(salary) OVER()) * 100, 2) as pct_of_overall_max,
    'PARTITION BY creates category-level aggregation, while omitting it gives overall aggregation' as explanation
FROM 
    employees
ORDER BY 
    department, 
    salary DESC;
