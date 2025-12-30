DROP DATABASE IF EXISTS company;
CREATE DATABASE company;
USE company;

CREATE TABLE employee (
ssn INT PRIMARY KEY,
name VARCHAR(50),
address VARCHAR(50),
sex VARCHAR(50),
salary DECIMAL(10,2),
superssn INT,
dno INT );

CREATE TABLE department (
dno INT PRIMARY KEY,
dname VARCHAR(50),
mgrssn INT,
mgrstartdate DATE,
FOREIGN KEY (mgrssn) REFERENCES employee(ssn) ON DELETE CASCADE);

CREATE TABLE dlocation (
dno INT PRIMARY KEY,
dloc VARCHAR(50),
FOREIGN KEY (dno) REFERENCES department(dno) ON DELETE CASCADE);

CREATE TABLE project (
pno INT PRIMARY KEY,
pname VARCHAR(50),
plocation VARCHAR(50),
dno INT,
FOREIGN KEY (dno) REFERENCES department(dno) ON DELETE CASCADE);

CREATE TABLE works_on (
ssn INT,
pno INT,
hours DECIMAL(6,2),
FOREIGN KEY (ssn) REFERENCES employee(ssn) ON DELETE CASCADE,
FOREIGN KEY (pno) REFERENCES project(pno) ON DELETE CASCADE);

INSERT INTO employee 
VALUES
    (111, 'Scott', '1st Main', 'Male', 700000.00, 112, 1),
    (112, 'Emma', '2nd Main', 'Female', 700000.00, NULL, 1),
    (113, 'Starc', '3rd Main', 'Male', 700000.00, 112, 1),
    (114, 'Sophie', '4th Main', 'Female', 700000.00, 112, 1),
    (115, 'Smith', '5th Main', 'Female', 700000.00, 112, 1),
    (116, 'David', '1st Main', 'Male', 60000.00, 112, 2),
    (117, 'Tom', '2nd Main', 'Female', 150000.00, NULL, 3),
    (118, 'Tim', '3rd Main', 'Male', 70000.00, 112, 4),
    (119, 'Yash', '4th Main', 'Female', 80000.00, 112, 5),
    (110, 'Smriti', '5th Main', 'Female', 90000.00, 112, 6);

INSERT INTO department 
VALUES
    (1, 'Accounts', 113, '2020-01-10'),
    (2, 'Finanace', 114, '2020-02-10'),
    (3, 'Research', 115, '2020-03-10'),
    (4, 'Sales', 115, '2020-04-10'),
    (5, 'Production', 112, '2020-05-10'),
    (6, 'Services', 114, '2020-07-20');

INSERT INTO dlocation 
VALUES
    (1, "London"),
    (2, "USA"),
    (3, "Qatar"),
    (4, "South Africa"),
    (5, "Australia");

INSERT INTO project 
VALUES
    (701, 'Project1', 'London', 1),
    (702, 'Project2', 'USA', 2),
    (703, 'Iot', 'Qatar', 3),
    (704, 'Internet', 'South Africa', 4),
    (705, 'Project5', 'Australia', 5);    

INSERT INTO works_on 
VALUES
    (111, 701, 120.1),
    (112, 702, 130.21),
    (113, 703, 130.41),
    (114, 704, 150.21),
    (115, 705, 90.89);  

SELECT * FROM employee;
SELECT * FROM department;
SELECT * FROM dlocation;
SELECT * FROM project;    
SELECT * FROM works_on;

-- 1. Make a list of all project numbers for projects that involve an employee whose last name 
-- is ‘Scott’, either as a worker or as a manager of the department that controls the project.  
SELECT * 
FROM project 
WHERE dno = (
    SELECT dno 
    FROM employee 
    WHERE name LIKE "%Scott%"
);

-- 2. Show the resulting salaries if every employee working on the ‘IoT’ project is given a 10 
-- percent raise. 
UPDATE employee 
SET salary = salary * 1.1
WHERE ssn = (
    SELECT ssn 
    FROM works_on 
    WHERE pno = (
        SELECT pno 
        FROM project 
        WHERE pname = 'IoT'
    )
);

-- Display the resulting salaries
SELECT ssn, name, salary
FROM employee
WHERE ssn = (
    SELECT ssn 
    FROM works_on 
    WHERE pno = (
        SELECT pno 
        FROM project 
        WHERE pname = 'IoT'
    )
);

-- CHECKING TABLE
SELECT * FROM employee;

-- 3. Find the sum of the salaries of all employees of the ‘Accounts’ department, as well as the 
-- maximum salary, the minimum salary, and the average salary in this department 
SELECT 
SUM(e.salary) AS TotalSalary,
MAX(e.salary) AS MaxSalary,
MIN(e.salary) AS MinSalary,
AVG(e.salary) AS AvgSalary 
FROM employee e 
JOIN department d ON e.dno = d.dno 
WHERE d.dname = 'Accounts';

-- 4. Retrieve the name of each employee who works on all the projects controlled by 
-- department number 5 (use NOT EXISTS operator). 
SELECT e.name 
FROM employee e 
WHERE NOT EXISTS (
    SELECT p.pno 
    FROM project p 
    WHERE p.dno = 5
    AND NOT EXISTS (
        SELECT w.pno 
        FROM works_on w 
        WHERE w.ssn = e.ssn AND w.pno = p.pno
    )
);

-- 5. For each department that has more than five employees, retrieve the department 
-- number and the number of its employees who are making more than Rs. 6,00,000. 
SELECT d.dno AS DepartmentNumber, COUNT(e.ssn) AS NumberOfEmployee
FROM department d 
JOIN employee e ON e.dno = d.dno 
WHERE e.salary > 600000
GROUP BY d.dno 
HAVING COUNT(e.ssn) >= 5;

-- 6. Create a view that shows name, dept name and location of all employees. 
CREATE OR REPLACE VIEW allinfo AS 
SELECT e.name, d.dname, dl.dloc
FROM employee e 
JOIN department d ON e.dno = d.dno
JOIN dlocation dl ON d.dno = dl.dno;

SELECT * FROM allinfo;

-- 7. Create a trigger that prevents a project from being deleted if it is currently being worked 
-- by any employee.
DELIMITER //

CREATE TRIGGER prevent_delete 
BEFORE DELETE ON project
FOR EACH ROW 
BEGIN 
    IF EXISTS (
        SELECT * FROM works_on 
        WHERE pno = OLD.pno
    ) THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The project cannot be deleted as it has an assigned employee';
    END IF;
END;
//

DELIMITER ;

-- CHECK TRIGGER
DELETE FROM project WHERE pno = 702;
