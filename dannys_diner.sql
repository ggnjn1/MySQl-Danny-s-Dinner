-- This is the solution for 1st case study of the challenge
-- CREATING DATA SET

CREATE TABLE sales
(
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


CREATE TABLE menu
(
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


CREATE TABLE members
(
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),

  ('B', '2021-01-09');

-- SOLUTIONS

-- 1. What is the total amount each customer spent at the restaurant?

SELECT S.customer_id, SUM (M.price) as total_amount
FROM sales S
  JOIN menu m ON m.product_id = s.product_id
GROUP BY S.customer_id

-- 2. How many days has each customer visited the restaurant?

SELECT customer_id, COUNT (DISTINCT order_date) as customer_visits
FROM sales
GROUP BY customer_id

-- 3. What was the first item from the menu purchased by each customer?

WITH RANKING
AS
(
  SELECT s.customer_id, s.order_date, m.product_name,
  ROW_NUMBER() OVER(PARTITION BY Customer_id ORDER BY order_date) as rnk
FROM sales s
  JOIN menu m ON m.product_id = s.product_id
)

SELECT *
FROM RANKING
WHERE rnk = 1

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT TOP 1
  m.product_name, COUNT(s. product_id) AS Purchase_count
FROM sales S
  JOIN menu m ON m.product_id = s.product_id
GROUP BY product_name
ORDER BY Purchase_count DESC

-- 5. Which item was the most popular for each customer?

WITH
  CTE
  AS
  (
    SELECT m.product_name, s.Customer_id, COUNT(s.product_id) AS Purchase_count,
      ROW_NUMBER() OVER(PARTITION BY Customer_id ORDER BY COUNT (s.product_id)DESC) AS rn
    FROM sales S
      JOIN menu m ON m.product_id = s.product_id
    GROUP BY product_name, Customer_id
  )

SELECT customer_id, Product_name
FROM CTE
WHERE rn = 1;

-- 6. Which item was purchased first by the customer after they became a member?

WITH
  CTE
  AS
  (
    SELECT M.join_date, s.order_date, s.product_id, m1.product_name, s.customer_id,
      DENSE_RANK() OVER (PARTITION BY M.join_date ORDER BY s.order_date) AS Rnk
    FROM Members M
      LEFT JOIN sales s ON M.customer_id = s.customer_id
      JOIN menu m1 ON M1.product_id = s.product_id
    WHERE order_date >= join_date
  )

SELECT customer_id, product_name
FROM CTE
WHERE rnk =1

-- 7. Which item was purchased just before the customer became a member?

WITH
  CTE
  AS
  (
    SELECT M.join_date, s.order_date, s.product_id, m1.product_name, s.customer_id,
      DENSE_RANK() OVER (PARTITION BY M.join_date ORDER BY s.order_date DESC) AS RNK
    FROM Members M
      LEFT JOIN sales s ON M.customer_id = s.customer_id
      JOIN menu m1 ON M1.product_id = s.product_id
    WHERE order_date < join_date
  )

SELECT customer_id, product_name
FROM CTE
WHERE RNK = 1

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id, SUM(M.PRICE) AS amount_spent, COUNT(S.order_date) AS total_items
FROM menu M
  JOIN sales s ON M.product_id = s.product_id
  JOIN Members M1 ON S.customer_id = M1.customer_id
WHERE M1.join_date > S.order_date
GROUP BY s.customer_id

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier,
--how many points would each customer have?

SELECT S.customer_id,
  SUM ( CASE
  WHEN m.product_name = 'Sushi' THEN 20 * m.price 
  ELSE 10 * m.price
  END ) AS Total_points
FROM Menu M
  JOIN Sales S ON m.product_id = S.product_id
GROUP BY S.customer_id

-- 10. In the first week after a customer joins the program (including their join date) 
--they earn 2x points on all items, not just sushi - 
--how many points do customer A and B have at the end of January?

SELECT M.customer_id,
  SUM(CASE
WHEN order_date BETWEEN M.join_date AND DATEADD( dd, 6, M.join_date ) THEN Price * 20
WHEN M1.Product_name = 'Sushi' THEN Price * 20
ELSE Price * 10
END)
AS Points
FROM Members M
  JOIN sales s ON M.customer_id  = s.customer_id
  JOIN Menu M1 ON S.product_id = M1.product_id
WHERE DATEPART(month, order_date) = 1
GROUP BY M.Customer_id

----------------------------------------BONUS QUESTIONS---------------------------------------------------------
SELECT *
FROM members
SELECT *
FROM menu
SELECT *
FROM sales

--JOIN ALL THE THINGS

SELECT s.customer_id, s.order_date, m.product_name, m.price,
  CASE 
	 WHEN join_date IS NULL THEN 'N'
	 WHEN order_date < join_date THEN 'N' 
	 ELSE 'Y'
     END AS member
FROM MENU m
  JOIN SALES s ON s.product_id = m.product_id
  LEFT JOIN MEMBERS m1 ON s.Customer_id = m1.Customer_id
ORDER BY customer_id, order_date, price desc

--- RANK ALL THE THINGS

WITH
  CTE
  AS
  (
    SELECT s.customer_id, s.order_date, m.product_name, m.price,
      CASE 
		 WHEN join_date IS NULL THEN 'N'
		 WHEN order_date < join_date THEN 'N' 
		 ELSE 'Y'
		 END AS member
    FROM MENU m
      JOIN SALES s ON s.product_id = m.product_id
      LEFT JOIN MEMBERS m1 ON s.Customer_id = m1.Customer_id
  )

SELECT *,
  CASE WHEN Member = 'N' THEN NULL
ELSE RANK() OVER (PARTITION BY customer_id, member ORDER BY order_date)
END AS Ranking
FROM CTE
ORDER BY customer_id, order_date, price desc