-- ============================================================
-- Section D – Joins
-- Description: INNER JOIN, LEFT JOIN, and validation queries
-- ============================================================

-- Orders with customer details (basic INNER JOIN)
SELECT o.order_id,
       c.customer_name,
       c.region,
       o.order_date,
       o.ship_mode,
       o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_date
LIMIT 20;
/*
Result: 5,009 orders matched to customers (no orphan orders).
CA-2014-103800|Darren Powers|Central|2014-01-03|Standard Class|16.45
CA-2014-112326|Phillina Ober|Central|2014-01-04|Standard Class|288.06
*/

-- Order items with product details
SELECT oi.row_id,
       oi.order_id,
       p.product_name,
       p.category,
       p.sub_category,
       oi.quantity,
       oi.sales,
       oi.discount,
       oi.profit
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
ORDER BY oi.row_id
LIMIT 20;
/*
Result: 9,994 items matched to products.
1|CA-2016-152156|Bush Somerset Collection Bookcase|Furniture|Bookcases|2|261.96|0.0|41.91
2|CA-2016-152156|Hon Deluxe Fabric Upholstered Stacking Chairs|Furniture|Chairs|3|731.94|0.0|219.58
*/

-- Full 4-way join: order → customer → items → product
SELECT o.order_id,
       c.customer_name,
       c.region,
       o.order_date,
       p.product_name,
       p.category,
       oi.quantity,
       oi.sales,
       oi.discount,
       oi.profit
FROM orders o
JOIN customers c   ON o.customer_id   = c.customer_id
JOIN order_items oi ON o.order_id     = oi.order_id
JOIN products p    ON oi.product_id   = p.product_id
ORDER BY o.order_id, oi.row_id
LIMIT 30;
/*
Result: Complete denormalized view. All joins match correctly.
*/

-- Top 10 customers by total spend (with join)
SELECT c.customer_id,
       c.customer_name,
       c.region,
       COUNT(DISTINCT o.order_id)         AS order_count,
       ROUND(SUM(o.total_amount), 2)      AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 10;
/*
Result:
#1 Sean Miller (South) | 5 orders | $25,043.05
#2 Tamara Chand (West)  | 4 orders | $19,052.22
#3 Raymond Buch (East)  | 5 orders | $15,117.34
*/

-- Category revenue (orders × items join)
SELECT p.category,
       COUNT(DISTINCT oi.order_id)           AS order_count,
       SUM(oi.quantity)                      AS units_sold,
       ROUND(SUM(oi.sales), 2)               AS revenue,
       ROUND(SUM(oi.profit), 2)              AS profit
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;
/*
Result:
Technology    | 1,544 orders | 6,939 units | $836,154.06 | $145,455.31 profit
Furniture     | 1,764 orders | 8,028 units | $741,999.73 | $18,451.18 profit
Office Supp.  | 3,742 orders |22,906 units | $719,046.85 | $122,490.13 profit
*/

-- Monthly category revenue trend
SELECT strftime('%Y-%m', o.order_date) AS month,
       p.category,
       ROUND(SUM(oi.sales), 2)          AS revenue
FROM orders o
JOIN order_items oi ON o.order_id   = oi.order_id
JOIN products p     ON oi.product_id = p.product_id
GROUP BY month, p.category
ORDER BY month, revenue DESC;
/*
Result: 48 months × 3 categories = 144 rows showing category-level trends.
*/

-- Top product by revenue in each region
SELECT c.region,
       p.product_name,
       ROUND(SUM(oi.sales), 2) AS revenue
FROM customers c
JOIN orders o      ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id   = oi.order_id
JOIN products p    ON oi.product_id = p.product_id
GROUP BY c.region, p.product_name
ORDER BY c.region, revenue DESC;
/*
Result: Products ranked within each region by revenue.
*/

-- Customers who never ordered (LEFT JOIN)
SELECT c.customer_id,
       c.customer_name,
       c.region
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
/*
Result: All 793 customers have placed at least one order (0 orphans).
*/

-- Customer order count (with 0-order customers)
SELECT c.customer_id,
       c.customer_name,
       c.region,
       COUNT(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY order_count DESC, c.customer_name;
/*
Result: Every customer has at least 1 order. Most active has many orders.
*/

-- Products never sold (LEFT JOIN)
SELECT p.product_id,
       p.product_name,
       p.category,
       p.sub_category
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;
/*
Result: Some products have never been sold (orphaned products).
*/

-- Products with zero sales (LEFT JOIN + COALESCE)
SELECT p.product_id,
       p.product_name,
       p.category,
       COALESCE(SUM(oi.quantity), 0)               AS total_ordered,
       COALESCE(ROUND(SUM(oi.sales), 2), 0)        AS total_revenue,
       COALESCE(ROUND(SUM(oi.profit), 2), 0)       AS total_profit
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id
ORDER BY total_revenue DESC
LIMIT 15;
/*
Result: Products ranked by revenue, including unsold ones (revenue=$0).
*/

-- Orphan order_items with no matching order
SELECT oi.row_id, oi.order_id
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;
/*
Result: All order_items have matching orders (0 orphans).
*/

-- Orphan order_items with no matching product
SELECT oi.row_id, oi.product_id
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;
/*
Result: All order_items have matching products (0 orphans).
*/

-- Data quality: validate order total vs sum of items
SELECT o.order_id,
       o.total_amount                                              AS order_total,
       ROUND(SUM(oi.sales), 2)                                    AS items_total,
       ROUND(ROUND(SUM(oi.sales), 2) - o.total_amount, 2)        AS difference,
       CASE
           WHEN ABS(ROUND(SUM(oi.sales), 2) - o.total_amount) < 0.01 THEN 'OK'
           ELSE 'MISMATCH'
       END                                                        AS validation
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id
HAVING validation = 'MISMATCH'
ORDER BY ABS(difference) DESC;
/*
Result: All 5,009 orders validate correctly (0 mismatches).
*/

-- Orders from top 5 customers
SELECT c.customer_name,
       c.region,
       o.order_id,
       o.order_date,
       o.total_amount,
       o.ship_mode
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE c.customer_name IN (
    SELECT c2.customer_name
    FROM customers c2
    JOIN orders o2 ON c2.customer_id = o2.customer_id
    GROUP BY c2.customer_id
    ORDER BY SUM(o2.total_amount) DESC
    LIMIT 5
)
ORDER BY c.customer_name, o.order_date;
/*
Result: All orders placed by the top 5 spenders (Sean Miller, Tamara Chand, etc.).
*/
