DROP DATABASE IF EXISTS Orders;
CREATE DATABASE Orders;
USE Orders;

CREATE TABLE customer (
cust_id INT PRIMARY KEY,
cname VARCHAR(50),
city VARCHAR(50));

CREATE TABLE order_ (
order_id INT PRIMARY KEY,
odate DATE,
cust_id INT,
order_amt INT,
FOREIGN KEY (cust_id) REFERENCES customer(cust_id) ON DELETE CASCADE);

CREATE TABLE item(
item_id INT PRIMARY KEY,
unitprice INT );

CREATE TABLE order_item (
order_id INT,
item_id INT ,
qty INT ,
FOREIGN KEY (order_id) REFERENCES order_(order_id) ON DELETE CASCADE,
FOREIGN KEY (item_id) REFERENCES item(item_id) ON DELETE CASCADE);

CREATE TABLE warehouse (
warehouse_id INT PRIMARY KEY,
city VARCHAR(50));

CREATE TABLE shipment (
order_id INT,
warehouse_id INT,
ship_date DATE,
FOREIGN KEY (order_id) REFERENCES order_(order_id) ON DELETE CASCADE,
FOREIGN KEY (warehouse_id) REFERENCES warehouse(warehouse_id) ON DELETE CASCADE);

INSERT INTO customer 
VALUES
    (101, 'Kumar', 'City1'),
    (102, 'Peter', 'City2'),
    (103, 'James', 'City3'),
    (104, 'Kevin', 'City4'),
    (105, 'Harry', 'City5');
    
INSERT INTO order_
VALUES
    (201, '2023-04-11', 101, 1567),
    (202, '2023-04-12', 102, 2567),
    (203, '2023-04-13', 103, 3567),
    (204, '2023-04-14', 104, 4567),
    (205, '2023-04-15', 105, 5567);

INSERT INTO item VALUES
    (1001, 100),
    (1002, 200),
    (1003, 300),
    (1004, 400),
    (1005, 500);
 
INSERT INTO order_item VALUES
    (201, 1001, 10),
    (202, 1002, 11),
    (203, 1003, 12),
    (204, 1004, 13),
    (205, 1005, 14); 
    
INSERT INTO warehouse VALUES
    (1, 'Wcity1'),
    (2, 'Wcity2'),
    (3, 'Wcity3'),
    (4, 'Wcity4'),
    (5, 'Wcity5');

INSERT INTO shipment VALUES
    (201, 1, '2023-05-01'),
    (202, 2, '2023-05-02'),
    (203, 3, '2023-05-03'),
    (204, 4, '2023-05-04'),
    (205, 5, '2023-05-05');

SELECT * FROM customer;
SELECT * FROM order_;
SELECT * FROM item;
SELECT * FROM order_item;
SELECT * FROM warehouse;
SELECT * FROM shipment;

-- 1. List the Order# and Ship_date for all orders shipped from Warehouse# "W2".
SELECT s.order_id, s.ship_date 
FROM shipment s 
WHERE s.warehouse_id = 2;

-- 2. List the Warehouse information from which the Customer named "Kumar" was supplied his orders.
-- Produce a listing of Order#, Warehouse#.
SELECT s.order_id, s.warehouse_id 
FROM shipment s 
JOIN order_ o ON s.order_id = o.order_id
JOIN customer c ON o.cust_id = c.cust_id 
WHERE c.cname = 'Kumar';

-- 3. Produce a listing: Cname, #ofOrders, Avg_Order_Amt
SELECT c.cname AS cust_name, COUNT(*) AS total_orders, AVG(order_amt) AS Avg_Order_Amt
FROM customer c
INNER JOIN order_ o ON c.cust_id = o.cust_id
GROUP BY c.cname, c.cust_id;

-- 4. Delete all orders for customer named "Kumar".
DELETE FROM order_ 
WHERE cust_id = (
    SELECT cust_id 
    FROM customer 
    WHERE cname = 'Kumar'
);

SELECT * FROM order_;

-- 5. Find the item with the maximum unit price. 
SELECT item_id, unitprice
FROM item 
WHERE unitprice = (SELECT MAX(unitprice) FROM item);

-- 6. A trigger that updates order_amount based on quantity and unitprice of order_item
DELIMITER //

CREATE TRIGGER update_order_amount 
BEFORE INSERT ON order_item 
FOR EACH ROW 
BEGIN 
  UPDATE order_ 
  SET order_amt = NEW.qty * (SELECT unitprice FROM item WHERE item_id = NEW.item_id)
  WHERE order_id = NEW.order_id;
END;
//

DELIMITER ;

-- CHECK
INSERT INTO item (item_id, unitprice) VALUES (1006, 600);

INSERT INTO order_ VALUES (206, '2023-04-16', 102, NULL);

INSERT INTO order_item VALUES (206, 1006, 5);

SELECT * FROM order_;

-- 7. Create a view to display orderID and shipment date of all orders shipped from warehouse 5
CREATE OR REPLACE VIEW all_orders AS
SELECT s.order_id, s.ship_date 
FROM shipment s 
WHERE s.warehouse_id = 5;

SELECT * FROM all_orders;
