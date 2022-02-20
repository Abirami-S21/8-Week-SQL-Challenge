CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

--Creating the tables from Danny's Diner from #8weeksql challenge
--Table1.Sales
CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');

--Table2.Menu
CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
--Table3.Members
CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
 
 --Visualise the table
SELECT * FROM sales;

SELECT * FROM menu;

SELECT * FROM members;
/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

SELECT a.customer_id, SUM(b.price)
FROM sales AS a 
INNER JOIN menu AS b
ON a.product_id = b.product_id
GROUP BY customer_id
ORDER BY customer_id;

-- 2. How many days has each customer visited the restaurant?

SELECT a.customer_id, 
	   COUNT(DISTINCT(a.order_date)) AS No_of_days_visited 
FROM sales AS a 
GROUP BY a.customer_id;

-- 3. What was the first item from the menu purchased by each customer?

SELECT DISTINCT ON(a.customer_id) a.customer_id, a.order_date, b.product_id, b.product_name 
	   FROM sales AS a 
	   LEFT JOIN menu AS b
	   ON a.product_id = b.product_id
ORDER BY a.customer_id, a.order_date, b.product_id;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT a.product_id, b.product_name, COUNT(a.product_id) FROM sales AS a LEFT JOIN menu AS b
	   ON a.product_id = b.product_id GROUP BY a.product_id, b.product_name ORDER BY COUNT(a.product_id) DESC;

-- 5. Which item was the most popular for each customer?

SELECT DISTINCT ON(a.customer_id) a.customer_id, b.product_name, COUNT(a.product_id)
FROM sales AS a
LEFT JOIN menu AS b
ON a.product_id = b.product_id  
GROUP BY a.customer_id, b.product_name 
ORDER BY a.customer_id, COUNT(a.product_id) DESC;

SELECT a.customer_id, b.product_name, COUNT(a.product_id) AS total 
FROM sales AS a 
LEFT JOIN menu AS b
ON a.product_id = b.product_id  
GROUP BY a.customer_id, b.product_name 
ORDER BY a.customer_id, COUNT(a.product_id) DESC;

--Using Dense Rank method
SELECT customer_id, product_name FROM
									(SELECT a.customer_id, b.product_name,
									 		DENSE_RANK() OVER 
												(PARTITION BY customer_id ORDER BY COUNT(a.product_id) DESC) product_rank 
									 				FROM sales AS a LEFT JOIN menu AS b
	  												 ON a.product_id = b.product_id GROUP BY a.customer_id, b.product_name)
								AS ranking 
WHERE product_rank = 1;
	   	   
-- 6. Which item was purchased first by the customer after they became a member?

SELECT customer_id, product_name FROM
									(SELECT a.customer_id, b.product_name, a.order_date,
									 		DENSE_RANK() OVER 
												(PARTITION BY a.customer_id ORDER BY a.order_date) AS product_rank 
									 				FROM sales AS a LEFT JOIN menu AS b
	  												 ON a.product_id = b.product_id 
									 					LEFT JOIN members As c
									 						ON a.customer_id = c.customer_id
									 							WHERE a.order_date >= c.join_date
									) AS ranking 
WHERE product_rank = 1;

-- 7. Which item was purchased just before the customer became a member?

SELECT customer_id, product_name FROM
									(SELECT a.customer_id, b.product_name, a.order_date,
									 		DENSE_RANK() OVER 
												(PARTITION BY a.customer_id ORDER BY a.order_date DESC) AS product_rank 
									 				FROM sales AS a LEFT JOIN menu AS b
	  												 ON a.product_id = b.product_id 
									 					LEFT JOIN members As c
									 						ON a.customer_id = c.customer_id
									 							WHERE a.order_date < c.join_date
									) AS ranking 
WHERE product_rank = 1;

-- 8. What is the total items and amount spent for each member before they became a member?

--Using dense_rank method

SELECT customer_id, COUNT(product_id) AS total_items, SUM(price) AS total_amount FROM
									(SELECT a.customer_id, b.product_name, a.order_date,a.product_id, b.price,
									 		DENSE_RANK() OVER 
												(PARTITION BY a.customer_id ORDER BY a.order_date DESC) AS product_rank 
									 				FROM sales AS a LEFT JOIN menu AS b
	  												 ON a.product_id = b.product_id 
									 					 LEFT JOIN members As c
									 						ON a.customer_id = c.customer_id
									 							WHERE a.order_date < c.join_date
									) AS ranking 
GROUP BY customer_id ORDER BY customer_id;

--Using simple join

SELECT a.customer_id, COUNT(a.product_id) AS total_items, SUM(b.price) AS total_amount
FROM sales AS a 
LEFT JOIN menu AS b
ON a.product_id = b.product_id 
LEFT JOIN members As c
ON a.customer_id = c.customer_id
WHERE a.order_date < c.join_date
GROUP BY a.customer_id ORDER BY a.customer_id;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?


SELECT a.customer_id,  
SUM(CASE WHEN b.product_name = 'sushi' THEN 2*b.price
	 WHEN b.product_name != 'sushi' THEN 1*b.price
	 END) points
FROM sales AS a 
LEFT JOIN menu AS b
ON a.product_id = b.product_id GROUP BY a.customer_id ORDER BY a.customer_id;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT c.customer_id,  
SUM(CASE WHEN c.join_date <= a.order_date and a.order_date < 7+ (c.join_date)  THEN 2*b.price
	 ELSE 1*b.price
	 END) points
FROM sales AS a 
LEFT JOIN menu AS b
ON a.product_id = b.product_id 
RIGHT JOIN members AS c
ON a.customer_id = c.customer_id
WHERE a.order_date < '2021-02-01' GROUP BY c.customer_id ORDER BY c.customer_id; 

