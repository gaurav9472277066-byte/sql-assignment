-- ============================================================
-- Section E – Advanced
-- Description: CASE statements, duplicate detection, transactions
-- ============================================================

-- ============================================================
-- CASE Statements
-- ============================================================

-- Order size classification
SELECT order_id, customer_id, order_date, total_amount,
    CASE
        WHEN total_amount < 100   THEN 'Small'
        WHEN total_amount < 500   THEN 'Medium'
        WHEN total_amount < 1500  THEN 'Large'
        ELSE                           'Very Large'
    END AS order_size
FROM orders
ORDER BY total_amount DESC
LIMIT 20;
/*
Result:
CA-2014-145317|SM-20320|2014-03-18|23661.23|Very Large
CA-2016-118689|TC-20980|2016-10-02|18336.74|Very Large
...
Most orders are "Medium" or "Large".
*/

-- Customer tier based on total spend (with CTE)
WITH spending AS (
    SELECT c.customer_name, c.region,
           ROUND(SUM(o.total_amount), 2) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
)
SELECT customer_name, region, total_spent,
    CASE
        WHEN total_spent < 500   THEN 'Bronze'
        WHEN total_spent < 2000  THEN 'Silver'
        WHEN total_spent < 5000  THEN 'Gold'
        ELSE                          'Platinum'
    END AS customer_tier
FROM spending
ORDER BY total_spent DESC
LIMIT 20;
/*
Result:
Sean Miller|South|25043.05|Platinum
Tamara Chand|West|19052.22|Platinum
...Top 20 are all Platinum ($5000+).
*/

-- Profitability classification per line item
SELECT oi.row_id, p.product_name, oi.sales, oi.profit,
    CASE
        WHEN oi.profit > 0              THEN 'Profitable'
        WHEN oi.profit = 0              THEN 'Break Even'
        ELSE                                 'Loss'
    END AS profit_category
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
ORDER BY oi.profit
LIMIT 20;
/*
Result: 1,871 items are Loss, 7,671 are Profitable, 452 are Break Even.
Worst loss: Cubify CubeX 3D Printer at -$6,599.98
*/

-- Shipping speed classification
SELECT order_id, order_date, ship_date,
       julianday(ship_date) - julianday(order_date) AS days_to_ship,
    CASE
        WHEN julianday(ship_date) - julianday(order_date) <= 2  THEN 'Fast'
        WHEN julianday(ship_date) - julianday(order_date) <= 5  THEN 'Normal'
        ELSE                                                          'Slow'
    END AS shipping_speed
FROM orders
ORDER BY days_to_ship DESC
LIMIT 20;
/*
Result: Max shipping time is 7 days. Range: Fast=0-2, Normal=3-5, Slow=6-7 days.
*/

-- Discount tier classification
SELECT oi.row_id, p.product_name, oi.sales, oi.discount, oi.profit,
    CASE
        WHEN oi.discount = 0       THEN 'No Discount'
        WHEN oi.discount <= 0.2    THEN 'Low Discount'
        WHEN oi.discount <= 0.5    THEN 'Medium Discount'
        ELSE                            'High Discount'
    END AS discount_tier
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
ORDER BY oi.discount DESC
LIMIT 20;
/*
Result: Max discount = 0.5 (50%).
High discount items often have negative profit (e.g., -$453.85 on $177.98 sale).
*/

-- ============================================================
-- Duplicate Detection (Use Case from Objective)
-- ============================================================

-- 1. Detect potential duplicate customers: same name, different IDs
SELECT c1.customer_id   AS id_a,
       c2.customer_id   AS id_b,
       c1.customer_name,
       c1.city,
       c1.state,
       c1.region
FROM customers c1
JOIN customers c2 ON c1.customer_name = c2.customer_name
                  AND c1.customer_id  < c2.customer_id
ORDER BY c1.customer_name;
/*
Result: (empty) — No duplicate customer names found. Data quality is good.
All 793 customers have unique names.
*/

-- 2. Detect potential duplicate products: same name, different IDs
SELECT p1.product_id   AS id_a,
       p2.product_id   AS id_b,
       p1.product_name,
       p1.category,
       p1.sub_category
FROM products p1
JOIN products p2 ON p1.product_name = p2.product_name
                  AND p1.product_id  < p2.product_id
ORDER BY p1.product_name;
/*
Result: Multiple duplicates found! Examples:
OFF-EN-10000461|OFF-EN-10000781|#10- 4 1/8" x 9 1/2" Recycled Envelopes
OFF-PA-10000249|OFF-PA-10000349|Easy-staple paper  (7+ product IDs!)
FUR-FU-10000023|FUR-FU-10003981|Eldon Wave Desk Accessories
TEC-MA-10001856|TEC-MA-10003230|Okidata C610n Printer
→ 30+ duplicate product entries flagged for cleanup.
*/

-- 3. Detect duplicate line items: same order + same product appearing twice
SELECT order_id,
       product_id,
       COUNT(*) AS occurrence_count
FROM order_items
GROUP BY order_id, product_id
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;
/*
Result: 8 order-product pairs appear twice (occurrence_count=2).
E.g.:
CA-2015-103135|OFF-BI-10000069|2
CA-2016-129714|OFF-PA-10001970|2
...
→ Minor data quality issue, likely data entry duplicates.
*/

-- 4. Detect potential duplicate orders: same customer, date, and amount
SELECT o1.order_id      AS order_a,
       o2.order_id      AS order_b,
       o1.customer_id,
       o1.order_date,
       o1.total_amount
FROM orders o1
JOIN orders o2 ON o1.customer_id  = o2.customer_id
              AND o1.order_date   = o2.order_date
              AND o1.total_amount = o2.total_amount
              AND o1.order_id     < o2.order_id
ORDER BY o1.customer_id, o1.order_date;
/*
Result: (empty) — No duplicate orders found. Good data quality.
*/

-- ============================================================
-- Transactions
-- ============================================================
BEGIN TRANSACTION;
INSERT INTO orders (order_id, customer_id, order_date, ship_date, ship_mode, total_amount)
VALUES ('NEW-ORDER-001', 'CG-12520', '2024-06-28', '2024-07-02', 'Standard Class', 0);
INSERT INTO order_items (order_id, product_id, quantity, sales, discount, profit)
VALUES ('NEW-ORDER-001', 'FUR-BO-10001798', 2, 523.92, 0.0, 83.83);
INSERT INTO order_items (order_id, product_id, quantity, sales, discount, profit)
VALUES ('NEW-ORDER-001', 'OFF-LA-10000240', 5, 36.55, 0.0, 17.18);
UPDATE orders
SET total_amount = (
    SELECT ROUND(SUM(sales), 2)
    FROM order_items
    WHERE order_id = 'NEW-ORDER-001'
)
WHERE order_id = 'NEW-ORDER-001';
SELECT * FROM orders WHERE order_id = 'NEW-ORDER-001';
SELECT * FROM order_items WHERE order_id = 'NEW-ORDER-001';
ROLLBACK;
/*
Transaction creates a new order with 2 items, calculates total, then rolls back.
Before ROLLBACK:
  orders: NEW-ORDER-001|CG-12520|2024-06-28|2024-07-02|Standard Class|560.47
  order_items: 2 items inserted (523.92 + 36.55 = 560.47)
After ROLLBACK: No changes persist.
*/
