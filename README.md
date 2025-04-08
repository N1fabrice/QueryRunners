What's This All About?
Hey there! This project dives into the fascinating world of SQL window functions using employee data. If you've ever struggled with complex SQL problems requiring multiple subqueries or self-joins, window functions might just be your new best friend!

Think of window functions as a way to look through a "window" of related rows while still keeping all your original data intact. They let us analyze data in context - comparing values, ranking items, and calculating aggregates - all while preserving each individual record.

Our Dataset: Meet the Employees
We're working with a simple but effective employee database in Oracle SQL. Our employees table contains:

employee_id: Each employee's unique ID number
first_name and last_name: Employee names
department: Which team they work in (IT, HR, Finance, Marketing)
salary: How much they earn
hire_date: When they joined the company
Setting Things Up
First, we create our table and add some employees:

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE employees';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE
);

INSERT ALL
    INTO Employees VALUES (1, 'John', 'Smith', 'IT', 75000.00, TO_DATE('2018-06-20', 'YYYY-MM-DD'))
    INTO Employees VALUES (2, 'Sarah', 'Jones', 'HR', 85000.00, TO_DATE('2015-03-14', 'YYYY-MM-DD'))
    INTO Employees VALUES (3, 'Michael', 'Brown', 'Finance', 95000.00, TO_DATE('2010-08-24', 'YYYY-MM-DD'))
    -- More employees here
SELECT * FROM dual;

COMMIT;


The Cool Stuff: 5 Powerful Window Function Techniques
1. Salary Comparison: Looking Forward and Backward
What we're doing: Comparing each employee's salary with the previous and next employees to see if they're earning more or less.
SELECT 
    employee_id,
    first_name || ' ' || last_name AS employee_name,
    department,
    salary,
    CASE 
        WHEN salary > LAG(salary) OVER(ORDER BY employee_id) THEN 'HIGHER'
        WHEN salary < LAG(salary) OVER(ORDER BY employee_id) THEN 'LOWER'
        WHEN salary = LAG(salary) OVER(ORDER BY employee_id) THEN 'EQUAL'
        ELSE 'FIRST RECORD' 
    END AS compared_to_previous,
    CASE 
        WHEN salary > LEAD(salary) OVER(ORDER BY employee_id) THEN 'HIGHER'
        WHEN salary < LEAD(salary) OVER(ORDER BY employee_id) THEN 'LOWER'
        WHEN salary = LEAD(salary) OVER(ORDER BY employee_id) THEN 'EQUAL'
        ELSE 'LAST RECORD' 
    END AS compared_to_next
FROM 
    employees
ORDER BY 
    employee_id;

   Why it's neat: The LAG function lets us peek at the previous employee's salary, while LEAD shows the next one's salary. It's like having eyes in the back and front of your head! This makes it super easy to spot trends in your data.

Here's what I got:

![Screenshot](https://github.com/N1fabrice/QueryRunners/blob/main/QUERY%20RESULT%201.jpg)



2. Department Rankings: Two Ways to Rank Employees
What we're doing: Ranking employees by salary within each department, using two different methods.
SELECT 
    employee_id,
    first_name || ' ' || last_name AS employee_name,
    department,
    salary,
    RANK() OVER(PARTITION BY department ORDER BY salary DESC) as rank_in_dept,
    DENSE_RANK() OVER(PARTITION BY department ORDER BY salary DESC) as dense_rank_in_dept,
    CASE 
        WHEN RANK() OVER(PARTITION BY department ORDER BY salary DESC) != 
             DENSE_RANK() OVER(PARTITION BY department ORDER BY salary DESC) 
        THEN '← Difference found here!'
        ELSE NULL
    END as notice_the_difference
FROM 
    employees
ORDER BY
    department,
    salary DESC;
   What's the difference? Imagine we have two employees tied for 1st place:

RANK() would put the next person at 3rd place (1, 1, 3, 4...)
DENSE_RANK() keeps it tight with no gaps (1, 1, 2, 3...)
Think of RANK() like Olympic medals (tied gold medalists are followed by bronze), while DENSE_RANK() is more like "you're the second-highest earner" even if you're tied with someone else.

Here's what I got:
![Screenshot](https://github.com/N1fabrice/QueryRunners/blob/main/QUERY%20RESULT%202.jpg)


3. The Top Performers: Finding the Highest Salaries by Department
What we're doing: Finding the top 3 highest-paid employees in each department.

WITH ranked_employees AS (
    SELECT 
        employee_id,
        first_name || ' ' || last_name AS employee_name,
        department,
        salary,
        DENSE_RANK() OVER(PARTITION BY department ORDER BY salary DESC) as salary_rank
    FROM 
        employees
)
SELECT 
    employee_id,
    employee_name,
    department,
    salary,
    salary_rank,
    CASE 
        WHEN salary_rank = 1 THEN '🥇 Top earner!'
        WHEN salary_rank = 2 THEN '🥈 Runner-up'
        WHEN salary_rank = 3 THEN '🥉 Third place'
    END as salary_medal
FROM 
    ranked_employees
WHERE 
    salary_rank <= 3
ORDER BY 
    department, 
    salary_rank;

    Why we used DENSE_RANK(): If two people tie for first place, we want to make sure we get both of them plus the next highest earner (not skip to the 3rd person). This gets us the true top 3 salary levels, even with ties.

Here's what I got:
![Screenshot](https://github.com/N1fabrice/QueryRunners/blob/main/QUERY%20RESULT%203.jpg)

4. The Veterans: Finding Who Joined First
What we're doing: Finding the first 2 employees who joined each department.
WITH ranked_by_hire_date AS (
    SELECT 
        employee_id,
        first_name || ' ' || last_name AS employee_name,
        department,
        hire_date,
        ROW_NUMBER() OVER(PARTITION BY department ORDER BY hire_date ASC) as hire_order
    FROM 
        employees
)
SELECT 
    employee_id,
    employee_name,
    department,
    hire_date,
    CASE 
        WHEN hire_order = 1 THEN 'Department Pioneer 🏆'
        WHEN hire_order = 2 THEN 'Second to Join 🥈'
    END as hire_status
FROM 
    ranked_by_hire_date
WHERE 
    hire_order <= 2
ORDER BY 
    department, 
    hire_date;

   Why we used ROW_NUMBER(): We want exactly 2 employees per department, even if they started on the same day. ROW_NUMBER() guarantees unique sequential numbers (1, 2, 3...) regardless of ties, so we always get exactly 2 people
   Here's what I got:
   ![Screenshot](https://github.com/N1fabrice/QueryRunners/blob/main/QUERY%20RESULT%204.jpg)

   

