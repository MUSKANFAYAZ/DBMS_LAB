DROP DATABASE IF EXISTS Sailors;

CREATE DATABASE Sailors;
USE Sailors;

CREATE TABLE sailors
(sid INT PRIMARY KEY,
 sname VARCHAR(50),
 rating INT,
 age INT);
 
CREATE TABLE boat
(bid INT PRIMARY KEY,
 bname VARCHAR(50),
 color VARCHAR(50));
  
CREATE TABLE reserves
(sid INT,
 bid INT,
 date DATE,
 FOREIGN KEY (sid) REFERENCES sailors(sid),
 FOREIGN KEY (bid) REFERENCES boat(bid));
 
INSERT INTO sailors VALUES
(1, 'Albert', 8, 41),
(2, 'Bob', 9, 45),
(3, 'Charlie', 9, 49),
(4, 'David', 8, 54),
(5, 'Eve', 7, 59);

INSERT INTO boat VALUES
(101, 'Boat1', 'Red'),
(102, 'Boat2', 'Blue'),
(103, 'Boat3', 'Green'),
(104, 'Boat4', 'Yellow'),
(105, 'Boat5', 'White');

INSERT INTO reserves VALUES
(1, 101, '2023-01-01'),
(1, 102, '2023-02-01'),
(1, 103, '2023-03-01'),
(1, 104, '2023-04-01'),
(1, 105, '2023-05-01'),
(1, 101, '2023-01-01'),
(2, 101, '2023-02-01'),
(3, 101, '2023-03-01'),
(4, 101, '2023-04-01'),
(5, 101, '2023-05-01'),
(2, 102, '2023-02-01'),
(3, 103, '2023-03-01'),
(4, 104, '2023-04-01'),
(5, 105, '2023-05-01');

SELECT * FROM sailors;
SELECT * FROM boat;
SELECT * FROM reserves;

-- 1. Find the colours of boats reserved by Albert 
SELECT DISTINCT b.color 
FROM boat b
JOIN reserves r ON b.bid = r.bid
WHERE r.sid = (
    SELECT s.sid 
    FROM sailors s
    WHERE s.sname = "Albert"
);

-- 2. Find all sailor id’s of sailors who have a rating of at least 8 OR reserved boat 103
SELECT DISTINCT s.sid
FROM sailors s 
JOIN reserves r ON s.sid = r.sid
WHERE s.rating >= 8 OR r.bid = 103;

-- 3. Find the names of sailors who have NOT reserved a boat whose name contains the string “storm”
-- Order the names in ascending order
SELECT s.sname 
FROM sailors s 
WHERE s.sid NOT IN 
(
    SELECT r.sid 
    FROM reserves r 
    JOIN boat b ON r.bid = b.bid 
    WHERE b.bname LIKE "%storm%"
)
ORDER BY s.sname ASC;
  
-- 4. Find the names of sailors who have reserved ALL boats
SELECT s.sname 
FROM sailors s 
WHERE NOT EXISTS (
    SELECT b.bid 
    FROM boat b 
    WHERE NOT EXISTS (
        SELECT r.bid 
        FROM reserves r 
        WHERE s.sid = r.sid AND b.bid = r.bid
    )
);

-- 5. Find the name and age of the oldest sailor
SELECT sname, age
FROM sailors 
ORDER BY age DESC
LIMIT 1;

-- another
SELECT sname, age 
FROM sailors 
WHERE age = (SELECT MAX(age) FROM sailors);

-- 6. For each boat which was reserved by at least 5 sailors with age >= 40,
-- find the boat id and the average age of such sailors
SELECT r.bid AS Boat_Id, AVG(s.age) AS Avg_age
FROM reserves r 
JOIN sailors s ON r.sid = s.sid
WHERE s.age >= 40
GROUP BY r.bid
HAVING COUNT(DISTINCT r.sid) >= 5;

-- 7. Create a view that shows the names and colours of all the boats
-- that have been reserved by a sailor with a specific rating
CREATE OR REPLACE VIEW ReservedBoatsByRating AS 
SELECT s.sname AS sailor_name, b.bname AS boat_name, b.color AS boat_color
FROM sailors s 
JOIN reserves r ON s.sid = r.sid
JOIN boat b ON r.bid = b.bid
WHERE s.rating = 8;

SELECT * FROM ReservedBoatsByRating;

-- 8. A trigger that prevents boats from being deleted if they have active reservations
DELIMITER //

CREATE TRIGGER prevent_delete_active_reservations
BEFORE DELETE ON boat 
FOR EACH ROW 
BEGIN 
    DECLARE reservation_count INT;
 
    SELECT COUNT(*) INTO reservation_count
    FROM reserves 
    WHERE bid = OLD.bid;
     
    IF reservation_count > 0 THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete a boat with active reservation';
    END IF;
END; 
//

DELIMITER ;
