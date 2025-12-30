DROP DATABASE IF EXISTS Insurance;
CREATE DATABASE Insurance;
USE Insurance;

CREATE TABLE person 
( driver_id VARCHAR(50) PRIMARY KEY,
  dname VARCHAR(50),
  address VARCHAR(50));
  
CREATE TABLE car(
regno VARCHAR(50) PRIMARY KEY,
model VARCHAR(50),
cyear INT 
);

CREATE TABLE accident(
report_number INT PRIMARY KEY,
acc_date DATE,
location VARCHAR(50));

CREATE TABLE owns(
driver_id VARCHAR(50),
regno VARCHAR(50),
FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
FOREIGN KEY (regno) REFERENCES car(regno) ON DELETE CASCADE);

CREATE TABLE participated (
driver_id VARCHAR(50),
regno VARCHAR(50),
report_number INT,
damage_amount INT,
FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
FOREIGN KEY (regno) REFERENCES car(regno) ON DELETE CASCADE,
FOREIGN KEY (report_number) REFERENCES accident(report_number));

INSERT INTO person VALUES
("D111", "Driver_1", "Kuvempunagar, Mysuru"),
("D222", "Smith", "JP Nagar, Mysuru"),
("D333", "Driver_3", "Udaygiri, Mysuru"),
("D444", "Driver_4", "Rajivnagar, Mysuru"),
("D555", "Driver_5", "Vijayanagar, Mysore");

INSERT INTO car VALUES
("KA-20-AB-4223", "Swift", 2020),
("KA-20-BC-5674", "Mazda", 2017),
("KA-21-AC-5473", "Alto", 2015),
("KA-21-BD-4728", "Triber", 2019),
("KA-09-MA-1234", "Tiago", 2018);

INSERT INTO accident VALUES
(43627, "2020-04-05", "Nazarbad, Mysuru"),
(56345, "2019-12-16", "Gokulam, Mysuru"),
(63744, "2020-05-14", "Vijaynagar, Mysuru"),
(54634, "2019-08-30", "Kuvempunagar, Mysuru"),
(65738, "2021-01-21", "JSS Layout, Mysuru"),
(66666, "2021-01-21", "JSS Layout, Mysuru"),
(45562, "2024-04-05", "Mandya"),
(49999, "2024-04-05", "kolkatta");

INSERT INTO owns VALUES
("D111", "KA-20-AB-4223"),
("D222", "KA-20-BC-5674"),
("D333", "KA-21-AC-5473"),
("D444", "KA-21-BD-4728"),
("D222", "KA-09-MA-1234");

INSERT INTO participated VALUES
("D111", "KA-20-AB-4223", 43627, 20000),
("D222", "KA-20-BC-5674", 56345, 49500),
("D333", "KA-21-AC-5473", 63744, 15000),
("D444", "KA-21-BD-4728", 54634, 5000),
("D222", "KA-09-MA-1234", 65738, 25000),
("D222", "KA-21-BD-4728", 45562, 50000),
("D222", "KA-21-BD-4728", 49999, 50000);

SELECT * FROM person;
SELECT * FROM car;
SELECT * FROM accident;
SELECT * FROM owns;
SELECT * FROM participated;

-- 1. Find the total number of people who owned cars that were involved in accidents in 2021.
SELECT COUNT(*)
FROM accident 
JOIN participated USING(report_number)
WHERE YEAR(acc_date) = 2021;

-- 2. Find the number of accidents in which the cars belonging to “Smith” were involved. 
SELECT COUNT(*)
FROM accident 
JOIN participated USING(report_number)
JOIN person USING(driver_id)
WHERE person.dname = 'Smith';

-- 3. Add a new accident to the database; assume any values for required attributes. 
INSERT INTO accident VALUES 
(46969,"2024-04-05","Mandya");

INSERT INTO participated VALUES
("D555", "KA-21-BD-4728", 46969, 50000);

SET sql_safe_updates = 0;

-- 4. Delete the Mazda belonging to “Smith”.   
DELETE FROM car
WHERE model = 'Mazda' 
AND regno IN ( 
    SELECT regno 
    FROM owns 
    JOIN person USING(driver_id) 
    WHERE dname = 'Smith'
);

-- 5. Update the damage amount for the car with license number “KA09MA1234” in the accident
-- with report.  
UPDATE participated 
SET damage_amount = 2000
WHERE regno = 'KA-09-MA-1234'
AND report_number = 65738;

-- 6. A view that shows models and year of cars that are involved in accident. 
CREATE OR REPLACE VIEW AccidentCars AS 
SELECT model, cyear 
FROM car 
JOIN participated USING (regno);

SELECT * FROM AccidentCars;

-- 7. A trigger that prevents a driver from participating in more than 3 accidents in a given year. 
DELIMITER //

CREATE TRIGGER preventParticipation
BEFORE INSERT ON participated
FOR EACH ROW
BEGIN
  IF 3 <= (SELECT COUNT(*) FROM participated WHERE driver_id = NEW.driver_id) THEN 
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Driver already in 3 accidents';
  END IF;
END;
// 

DELIMITER ;
