-- Practice Joins
-- 1
SELECT *
FROM invoice 
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
WHERE invoice_line.unit_price > 0.99;
-- 2
SELECT i.invoice_date, cu.first_name, cu.last_name, i.total
FROM invoice i
JOIN customer cu ON i.customer_id = cu.customer_id;
-- 3
SELECT c.first_name, c.last_name, s.first_name, s.last_name
FROM customer c, employee s
WHERE c.support_rep_id = s.employee_id; 
-- 4
SELECT al.title, ar.name
FROM album al, artist ar
WHERE ar.artist_id = al.artist_id;
-- 5
SELECT pt.track_id
FROM playlist_track pt
JOIN playlist p ON pt.playlist_id = p.playlist_id
WHERE p.name = 'Music'; 
-- 6
SELECT t.name
FROM track t
JOIN playlist_track pt ON pt.track_id = t.track_id
WHERE pt.playlist_id = 5; 
-- 7
SELECT t.name, p.name
FROM playlist_track pt
JOIN track t ON t.track_id = pt.track_id
JOIN playlist p ON p.playlist_id = pt.playlist_id
-- 8
SELECT t.name, a.title
FROM track t
JOIN album a ON t.album_id = a.album_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Alternative & Punk';
-- Black Diamond
SELECT t.name, g.name, al.title, ar.name
FROM playlist_track pt 
JOIN playlist p ON pt.playlist_id = p.playlist_id
JOIN track t ON pt.track_id = t.track_id
JOIN genre g ON g.genre_id = t.genre_id
JOIN album al ON al.album_id = t.album_id
JOIN artist ar ON ar.artist_id = al.artist_id
WHERE p.name = 'Music';

-- Practice nested queries
-- 1
SELECT *
FROM invoice
WHERE invoice_id IN (
  SELECT invoice_id
  FROM invoice_line
  WHERE unit_price >0.99
);
-- 2
SELECT *
FROM playlist_track 
WHERE playlist_id IN (
  SELECT playlist_id
  FROM playlist
  WHERE name = 'Music'
); 
-- 3
SELECT name
FROM track
WHERE track_id IN (
  SELECT track_id 
  FROM playlist_track
  WHERE playlist_id = 5
); 
-- 4
SELECT *
FROM track 
WHERE genre_id IN (
  SELECT genre_id
  FROM genre
  WHERE name = 'Comedy'
);
-- 5
SELECT *
FROM track
WHERE album_id IN (
  SELECT album_id
  FROM album
  WHERE title = 'Fireball'
)
-- 6
SELECT *
FROM track
WHERE album_id IN (
  SELECT album_id
  FROM album
  WHERE artist_id IN (
    SELECT artist_id
    FROM artist
    WHERE name = 'Queen'
  )
);
-- Practice updating Rows
-- 1
UPDATE customer
SET fax = null
WHERE fax IS NOT null;
-- 2
UPDATE customer
SET company = 'Self'
WHERE company IS null; 
-- 3
UPDATE customer
SET last_name = 'Thompson'
WHERE first_name = 'Julia' AND last_name = 'Barnett';
-- 4
UPDATE customer
SET support_rep_id = 4
WHERE email = 'luisrojas@yahoo.cl';
-- 5
UPDATE track
SET composer = 'The darkness around us'
WHERE genre_id IN (
  SELECT genre_id
  FROM genre
  WHERE name = 'Metal'
)
AND composer IS null;
-- Group By Practice
-- 1
SELECT COUNT(t.name), g.name
FROM track t, genre g
WHERE t.genre_id = g.genre_id
GROUP BY g.name;
-- 2
SELECT COUNT(t.name), g.name
FROM track t, genre g
WHERE t.genre_id = g.genre_id
AND g.name ='Pop' OR g.name = 'Rock'
GROUP BY g.name;
-- 3
SELECT ar.name, COUNT(al.title)
from album al
JOIN artist ar ON ar.artist_id = al.artist_id
GROUP BY ar.name;  
-- Use Distinct
-- 1
SELECT DISTINCT composer
FROM track
WHERE composer IS NOT null; 
-- 2
SELECT DISTINCT billing_postal_code
FROM invoice
WHERE billing_postal_code IS NOT null; 
-- 3
SELECT DISTINCT company
FROM customer
WHERE company IS NOT null; 
-- Delete Rows
-- 1 -> Done
-- 2
DELETE 
FROM practice_delete
WHERE type = 'bronze';
-- 3
DELETE
FROM practice_delete
WHERE type = 'silver';
-- 4
DELETE
FROM practice_delete
WHERE value = 150; 
-- eCommerce Simulation - No Hints
-- Create Tables
CREATE TABLE customer (
  user_id SERIAL PRIMARY KEY,
  name TEXT,
  email TEXT
);

CREATE TABLE product (
  product_id SERIAL PRIMARY KEY,
  name TEXT,
  price FLOAT
);

CREATE TABLE product_order (
  id SERIAL PRIMARY KEY,
  order_id INT, 
  product_id INT REFERENCES product(product_id)
);


INSERT INTO customer 
(name, email)
VALUES
('Bob','bob@bob.com'),
('Joe','Joe@bob.com'),
('Sue','Sue@bob.com'),
('Jef','Jef@bob.com'),
('Kat','Kat@bob.com');

INSERT INTO product
(name, price)
VALUES
('kite',20.99),
('sailboat',40000.99),
('coffee grinder',40.99),
('toaster',30.99),
('mug',4.99);

INSERT INTO product_order
(order_id, product_id)
VALUES
(1,1),(1,2),(2,3),(2,4),(2,4),(3,3),(4,5),(5,5),(5,5),(5,1);

-- Run Queries
-- Get all products for the first order
SELECT p.name
FROM product_order po, product p
WHERE po.product_id = p.product_id
AND po.order_id=1;
-- Get all orders
SELECT po.order_id, p.name, p.price
FROM product_order po
JOIN product p ON po.product_id = p.product_id
ORDER BY po.order_id; 
-- Get the total cost of an order
SELECT SUM(p.price)
FROM product_order po, product p
WHERE po.product_id = p.product_id
AND po.order_id=1;
-- Add a foreign key reference from orders to users.
-- Update the orders table to link a user to each order.
ALTER TABLE product_order
ADD COLUMN user_id INT
REFERENCES customer (user_id); 

-- Add faux user data to table (from stack overflow)
UPDATE product_order po 
SET user_id = c.replace_column
FROM (
  VALUES
    (1,1),
    (2,2), 
    (3,3),
    (4,4), 
    (5,5)
) as c (check_column, replace_column) 
where c.check_column = po.order_id;

--  Add additional faux data to give some users multiple orders
INSERT INTO product_order 
(order_id, product_id, user_id)
VALUES
(6,1,1),
(6,2,1),
(7,3,2),
(8,4,3),
(8,5,3),
(9,1,4),
(9,2,4),
(10,3,5),
(10,4,5),
(11,5,5);


-- Run queries against your data.
-- Get all orders for a user.
SELECT po.order_id, p.name, p.price
FROM product_order po
JOIN product p ON po.product_id = p.product_id
WHERE po.user_id IN (
  SELECT user_id
  FROM customer
  WHERE name = 'Bob'
)
ORDER BY po.order_id; 

-- Get how many orders each user has.
SELECT c.name, COUNT(DISTINCT(po.user_id, order_id))
FROM customer c, product_order po
WHERE c.user_id = po.user_id
GROUP BY c.user_id;

-- Black Diamond
-- Get the total amount on all orders for each user.

SELECT c.name, SUM(p.price)
FROM product_order po
JOIN customer c ON po.user_id = c.user_id
JOIN product p ON po.product_id = p.product_id
GROUP BY c.user_id; 

