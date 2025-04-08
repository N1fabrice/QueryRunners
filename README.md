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
