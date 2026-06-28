-- ============================================================
-- Section B – Filtering
-- Description: WHERE filters by region, category, date, sales
--              and query optimization with EXPLAIN
-- ============================================================

-- Customers in the West region
SELECT customer_id, customer_name, city, state, region
FROM customers
WHERE region = 'West'
ORDER BY customer_name;
/*
Result: 255 customers in West region. E.g.:
AB-10015|Aaron Bergman|Seattle|Washington|West
AB-10105|Adrian Barton|Phoenix|Arizona|West
AH-10120|Adrian Hane|Tucson|Arizona|West
*/

-- Customers in the East region
SELECT customer_id, customer_name, city, state, region
FROM customers
WHERE region = 'East'
ORDER BY customer_name;
/*
Result: 220 customers in East region.
*/

-- Corporate segment customers
SELECT customer_id, customer_name, segment, region
FROM customers
WHERE segment = 'Corporate'
ORDER BY customer_name;
/*
Result: 236 corporate customers. E.g.:
AH-10030|Aaron Hawkins|Corporate|East
AS-10045|Aaron Smayling|Corporate|South
AH-10075|Adam Hart|Corporate|East
*/

-- Home Office and Consumer segments
SELECT customer_id, customer_name, segment, region
FROM customers
WHERE segment IN ('Home Office', 'Consumer')
ORDER BY segment, customer_name;
/*
Result: 557 customers (409 Consumer + 148 Home Office).
*/

-- Technology products
SELECT product_id, product_name, category, sub_category
FROM products
WHERE category = 'Technology'
ORDER BY product_name;
/*
Result: 404 Technology products. E.g.:
TEC-MA-10001047|3D Systems Cube Printer|Technology|Machines
TEC-PH-10000169|ARKON Windshield Dashboard Mount|Technology|Phones
*/

-- Office Supplies products
SELECT product_id, product_name, category, sub_category
FROM products
WHERE category = 'Office Supplies'
ORDER BY product_name;
/*
Result: 1083 Office Supplies products.
*/

-- Furniture products
SELECT product_id, product_name, category, sub_category
FROM products
WHERE category = 'Furniture'
ORDER BY product_name;
/*
Result: 375 Furniture products.
*/

-- Orders in 2015
SELECT order_id, customer_id, order_date, ship_mode, total_amount
FROM orders
WHERE order_date BETWEEN '2015-01-01' AND '2015-12-31'
ORDER BY order_date;
/*
Result: 1038 orders placed in 2015.
*/

-- Orders in Q1 2016
SELECT order_id, customer_id, order_date, ship_mode, total_amount
FROM orders
WHERE order_date >= '2016-01-01' AND order_date < '2016-04-01'
ORDER BY order_date;
/*
Result: 179 orders in Q1 2016.
*/

-- Standard Class shipments
SELECT order_id, customer_id, order_date, ship_mode, total_amount
FROM orders
WHERE ship_mode = 'Standard Class'
ORDER BY order_date;
/*
Result: 2994 orders shipped Standard Class (59.8% of all orders).
*/

-- Same Day shipments
SELECT order_id, customer_id, order_date, ship_date, total_amount
FROM orders
WHERE ship_mode = 'Same Day'
ORDER BY order_date;
/*
Result: 264 orders shipped Same Day.
*/

-- High-value orders (>$1000)
SELECT order_id, customer_id, order_date, total_amount
FROM orders
WHERE total_amount > 1000
ORDER BY total_amount DESC;
/*
Result: Top orders exceed $23K. E.g.:
CA-2014-145317|SM-20320|2014-03-18|23661.23
CA-2016-118689|TC-20980|2016-10-02|18336.74
CA-2017-140151|RB-19360|2017-03-23|14052.48
*/

-- Low-value orders (<$50)
SELECT order_id, customer_id, order_date, total_amount
FROM orders
WHERE total_amount < 50
ORDER BY total_amount;
/*
Result: E.g.:
CA-2017-124114|RS-19765|2017-03-02|0.56
CA-2016-168361|KB-16600|2016-06-21|0.84
CA-2014-112403|JO-15280|2014-03-31|0.85
*/

-- Orders shipped in October 2017
SELECT order_id, customer_id, order_date, ship_date, ship_mode, total_amount
FROM orders
WHERE ship_date BETWEEN '2017-10-01' AND '2017-10-31'
ORDER BY ship_date;
/*
Result: 147 orders shipped in October 2017.
*/

-- Orders between $200 and $500
SELECT order_id, customer_id, order_date, total_amount
FROM orders
WHERE total_amount BETWEEN 200 AND 500
ORDER BY total_amount;
/*
Result: Moderate-value orders in the $200-$500 range.
*/

-- California customers
SELECT customer_id, customer_name, city, state, region
FROM customers
WHERE state = 'California'
ORDER BY customer_name;
/*
Result: 161 customers from California (most from any state).
*/

-- Central and South regions combined
SELECT customer_id, customer_name, city, state, region
FROM customers
WHERE region IN ('Central', 'South')
ORDER BY region, customer_name;
/*
Result: 318 customers (184 Central + 134 South).
*/

-- Products containing "Table"
SELECT product_id, product_name, category, sub_category
FROM products
WHERE product_name LIKE '%Table%'
ORDER BY product_name;
/*
Result: Products with "Table" in name span categories:
OFF-AP-10002495|Acco Smartsocket Table Surge Protector|Office Supplies|Appliances
FUR-TA-10003837|Anderson Hickey Conga Table Tops & Accessories|Furniture|Tables
*/

-- High-value orders after June 2016
SELECT order_id, customer_id, order_date, total_amount
FROM orders
WHERE order_date > '2016-06-01'
  AND total_amount > 500
ORDER BY total_amount DESC;
/*
Result: Large orders from H2 2016 onward.
*/

-- Heavy discounts (>50%)
SELECT row_id, order_id, product_id, quantity, sales, discount, profit
FROM order_items
WHERE discount > 0.5
ORDER BY discount DESC;
/*
Result: 0 items have discount >50%. Max discount is exactly 0.5 (50%).
*/

-- Loss-making items (negative profit)
SELECT row_id, order_id, product_id, quantity, sales, discount, profit
FROM order_items
WHERE profit < 0
ORDER BY profit
LIMIT 20;
/*
Result: 1871 items (18.7% of all items) are sold at a loss.
Average loss per item: -$83.45
Most unprofitable: Cubify CubeX 3D Printer Double/Triple Head Print (-$6599.98)
*/

-- Orders with shipping >7 days
SELECT order_id, customer_id, order_date, ship_date,
       julianday(ship_date) - julianday(order_date) AS days_to_ship,
       total_amount
FROM orders
WHERE julianday(ship_date) - julianday(order_date) > 7
ORDER BY days_to_ship DESC;
/*
Result: No orders take more than 7 days. Max = 7 days, Avg = 4 days, Min = 0 (same day).
*/

-- Query plan for indexed filter
EXPLAIN QUERY PLAN
SELECT customer_id, customer_name, city, region
FROM customers
WHERE region = 'West'
ORDER BY customer_name;
/*
Result: Uses the idx_customers_region index (SCAN).
*/
