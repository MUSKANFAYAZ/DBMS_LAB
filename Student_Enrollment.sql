DROP DATABASE IF EXISTS Student_Enrollment;
CREATE DATABASE Student_Enrollment;
USE Student_Enrollment;

CREATE TABLE student (
regno VARCHAR(50) PRIMARY KEY,
name VARCHAR(50),
major VARCHAR(50),
bdate DATE);

CREATE TABLE course (
course INT PRIMARY KEY,
cname VARCHAR(50),
dept VARCHAR(50));

CREATE TABLE enroll (
regno VARCHAR(50),
course INT,
sem INT,
marks INT,
FOREIGN KEY (regno) REFERENCES student(regno) ON DELETE CASCADE,
FOREIGN KEY (course) REFERENCES course(course) ON DELETE CASCADE);

CREATE TABLE text (
book_isbn INT PRIMARY KEY,
title VARCHAR(50),
publisher VARCHAR(50),
author VARCHAR(50));

CREATE TABLE book_adoption ( 
course INT,
sem INT,
book_isbn INT,
FOREIGN KEY (course) REFERENCES course(course) ON DELETE CASCADE,
FOREIGN KEY (book_isbn) REFERENCES text(book_isbn) ON DELETE CASCADE);

INSERT INTO student VALUES
("01HF235", "Student_1", "CSE", "2001-05-15"),
("01HF354", "Student_2", "Literature", "2002-06-10"),
("01HF254", "Student_3", "Philosophy", "2000-04-04"),
("01HF653", "Student_4", "History", "2003-10-12"),
("01HF234", "Student_5", "Computer Economics", "2001-10-10"),
("01HF699", "Student_6", "Computer Economics", "2001-10-10");

INSERT INTO course VALUES
(001, "DBMS", "CS"),
(002, "Literature", "English"),
(003, "Philosophy", "Philosphy"),
(004, "History", "Social Science"),
(005, "Computer Economics", "CS");

INSERT INTO enroll VALUES
("01HF235", 001, 5, 85),
("01HF354", 002, 6, 87),
("01HF254", 003, 3, 95),
("01HF653", 004, 3, 80),
("01HF234", 005, 5, 75),
("01HF699", 001, 6, 90);

INSERT INTO text VALUES
(241563, "Operating Systems", "Pearson", "Silberschatz"),
(532678, "Complete Works of Shakesphere", "Oxford", "Shakesphere"),
(453723, "Immanuel Kant", "Delphi Classics", "Immanuel Kant"),
(278345, "History of the world", "The Times", "Richard Overy"),
(426784, "Behavioural Economics", "Pearson", "David Orrel"),
(469691, "Code with Fun", "Tim David", "David Warner"),
(767676, "Fun & philosophy","Delphi Classics", "Immanuel Kant");

INSERT INTO book_adoption VALUES
(001, 5, 241563),
(002, 6, 532678),
(003, 3, 453723),
(004, 3, 278345),
(001, 6, 426784),
(001, 5, 469691),
(003, 6, 767676);

SELECT * FROM student;
SELECT * FROM course;
SELECT * FROM enroll;
SELECT * FROM text;
SELECT * FROM book_adoption;

-- 1. Demonstrate how you add a new text book to the database and make this book be 
-- adopted by some department.
INSERT INTO text VALUES (987654, "New Textbook", "New Publisher", "New Author");
SELECT * FROM text;

INSERT INTO book_adoption VALUES (001, 5, 987654);
SELECT * FROM book_adoption;

-- 2. Produce a list of text books (include Course #, Book-ISBN, Book-title) in the alphabetical 
-- order for courses offered by the ‘CS’ department that use more than two books.
SELECT b.course, b.book_isbn, t.title 
FROM book_adoption b
JOIN course c ON b.course = c.course 
JOIN text t ON b.book_isbn = t.book_isbn 
WHERE c.dept = 'CS'
AND b.course IN (
    SELECT course 
    FROM book_adoption
    GROUP BY course 
    HAVING COUNT(book_isbn) > 2
)
ORDER BY t.title ASC;

-- 3. List any department that has all its adopted books published by a specific publisher.
SELECT dept 
FROM course 
WHERE dept IN (
    SELECT dept 
    FROM course 
    JOIN book_adoption USING(course)
    JOIN text USING(book_isbn)
    WHERE publisher = 'Delphi Classics'
)
AND dept NOT IN (
    SELECT dept 
    FROM course 
    JOIN book_adoption USING(course)
    JOIN text USING(book_isbn)
    WHERE publisher != 'Delphi Classics'
);

-- 4. List the students who have scored maximum marks in ‘DBMS’ course.
SELECT s.regno, s.name, e.marks
FROM student s 
JOIN enroll e ON s.regno = e.regno
JOIN course c ON e.course = c.course 
WHERE c.cname = 'DBMS' 
ORDER BY e.marks DESC 
LIMIT 1;

-- 5. Create a view to display all the courses opted by a student along with marks obtained.
CREATE OR REPLACE VIEW StudentCourses AS
SELECT regno, course, cname, marks
FROM enroll 
JOIN course USING(course);

SELECT * FROM StudentCourses;

-- 6. Create a trigger that prevents a student from enrolling in a course if the marks 
-- prerequisite is less than 40.
DELIMITER //

CREATE TRIGGER PreventEnrollment 
BEFORE INSERT ON enroll
FOR EACH ROW 
BEGIN 
    IF NEW.marks < 40 THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Marks prerequisite not met for enrollment';
    END IF;
END;
//

DELIMITER ;

-- CHECK TRIGGER
INSERT INTO student 
VALUES ('01HF999', 'John Doe', 'Computer Science', '2000-01-01');

INSERT INTO enroll 
VALUES ('01HF999', 1, 7, 32);
