USE olist;

-- Q1: Monthly revenue and delivered orders
SELECT
  DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
  COUNT(DISTINCT o.order_id) AS total_orders,
  SUM(oi.price) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY month
ORDER BY month;

-- Q2: Top 10 product categories by revenue (delivered orders)
SELECT
  ct.product_category_name_english AS category,
  ROUND(SUM(oi.price), 2) AS revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN category_translation ct ON p.product_category_name = ct.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY ct.product_category_name_english
ORDER BY revenue DESC
LIMIT 10;

-- Q3: State-wise customers, orders and revenue (delivered orders)
SELECT
  c.customer_state AS state,
  COUNT(DISTINCT c.customer_unique_id) AS customers,
  COUNT(DISTINCT o.order_id) AS orders,
  ROUND(SUM(oi.price), 2) AS revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue DESC;

-- Q4: Average delivery days per customer state
SELECT
  c.customer_state AS state,
  COUNT(*) AS orders,
  ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 1) AS avg_delivery_days
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days DESC;

-- Q5: Late delivery % (delivered after estimated date)
SELECT
  COUNT(*) AS delivered_orders,
  SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) AS late_orders,
  ROUND(100 * SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) / COUNT(*), 2) AS late_pct
FROM orders o
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL;

-- Q5b: State-wise late delivery % (states with 100+ delivered orders)
SELECT
  c.customer_state AS state,
  COUNT(*) AS delivered_orders,
  SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) AS late_orders,
  ROUND(100 * SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) / COUNT(*), 2) AS late_pct
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(*) >= 100
ORDER BY late_pct DESC;

-- Q6: Month-over-month revenue growth using LAG (from 2017-01)
WITH monthly AS (
  SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    ROUND(SUM(oi.price), 2) AS revenue
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  WHERE o.order_status = 'delivered'
    AND o.order_purchase_timestamp >= '2017-01-01'
  GROUP BY month
)
SELECT
  month,
  revenue,
  LAG(revenue) OVER (ORDER BY month) AS prev_revenue,
  ROUND(100 * (revenue - LAG(revenue) OVER (ORDER BY month))
        / LAG(revenue) OVER (ORDER BY month), 1) AS mom_growth_pct
FROM monthly
ORDER BY month;

-- Q7: Top 5 categories per year with RANK() and PARTITION BY (2018 = Jan-Aug only)
WITH cat_year AS (
  SELECT
    YEAR(o.order_purchase_timestamp) AS yr,
    ct.product_category_name_english AS category,
    ROUND(SUM(oi.price), 2) AS revenue
  FROM order_items oi
  JOIN orders o ON oi.order_id = o.order_id
  JOIN products p ON oi.product_id = p.product_id
  JOIN category_translation ct ON p.product_category_name = ct.product_category_name
  WHERE o.order_status = 'delivered'
    AND YEAR(o.order_purchase_timestamp) IN (2017, 2018)
  GROUP BY yr, category
),
ranked AS (
  SELECT
    yr, category, revenue,
    RANK() OVER (PARTITION BY yr ORDER BY revenue DESC) AS rnk
  FROM cat_year
)
SELECT yr, rnk, category, revenue
FROM ranked
WHERE rnk <= 5
ORDER BY yr, rnk;

-- Q8: Repeat vs one-time customers (by customer_unique_id, delivered orders)
WITH cust AS (
  SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS orders
  FROM customers c
  JOIN orders o ON c.customer_id = o.customer_id
  WHERE o.order_status = 'delivered'
  GROUP BY c.customer_unique_id
)
SELECT
  CASE WHEN orders = 1 THEN 'one-time' ELSE 'repeat' END AS customer_type,
  COUNT(*) AS customers,
  ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM cust), 2) AS pct
FROM cust
GROUP BY customer_type;
