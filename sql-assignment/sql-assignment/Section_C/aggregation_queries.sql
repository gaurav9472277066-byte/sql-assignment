-- ============================================================
-- Section C – Aggregation
-- Description: GROUP BY with COUNT, SUM, AVG, MAX, MIN
-- ============================================================

-- Customer count by region
SELECT region, COUNT(*) AS customer_count
FROM customers
GROUP BY region
ORDER BY customer_count DESC;
/*
Result: West=255, East=220, Central=184, South=134
*/

-- Customer count by segment
SELECT segment, COUNT(*) AS customer_count
FROM customers
GROUP BY segment
ORDER BY customer_count DESC;
/*
Result: Consumer=409, Corporate=236, Home Office=148
*/

-- Product count by category
SELECT category, COUNT(*) AS product_count
FROM products
GROUP BY category
ORDER BY product_count DESC;
/*
Result: Office Supplies=1083, Technology=404, Furniture=375
*/

-- Product count by category and sub-category (top 10)
SELECT category, sub_category, COUNT(*) AS product_count
FROM products
GROUP BY category, sub_category
ORDER BY product_count DESC
LIMIT 10;
/*
Result: Paper=276, Binders=210, Phones=184, Furnishings=182, Art=163, ...
*/

-- Order count by ship mode
SELECT ship_mode, COUNT(*) AS order_count
FROM orders
GROUP BY ship_mode
ORDER BY order_count DESC;
/*
Result: Standard Class=2994, Second Class=964, First Class=787, Same Day=264
*/

-- Category performance: sales, avg, quantity, orders, profit
SELECT p.category,
       ROUND(SUM(oi.sales), 2)        AS total_sales,
       ROUND(AVG(oi.sales), 2)        AS avg_sale_per_item,
       SUM(oi.quantity)               AS total_units_sold,
       COUNT(DISTINCT oi.order_id)    AS order_count,
       ROUND(SUM(oi.profit), 2)       AS total_profit
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_sales DESC;
/*
Result:
Technology  | $836,154.06 | $452.71/item | 6,939 units | 1,544 orders | $145,455.31 profit
Furniture   | $741,999.73 | $349.83/item | 8,028 units | 1,764 orders | $18,451.18 profit
Office Supp.| $719,046.85 | $119.32/item |22,906 units | 3,742 orders | $122,490.13 profit
*/

-- Monthly order trends
SELECT strftime('%Y-%m', order_date) AS month,
       COUNT(*)                       AS order_count,
       ROUND(SUM(total_amount), 2)   AS revenue
FROM orders
GROUP BY month
ORDER BY month;
/*
Result: 48 months of data (2014-01 to 2017-12).
Revenue peaks in Nov/Dec each year (holiday season).
2017-11 has the highest: 261 orders, $118,447.85 revenue.
*/

-- Yearly trends
SELECT strftime('%Y', order_date) AS year,
       COUNT(*)                    AS order_count,
       ROUND(SUM(total_amount), 2) AS revenue,
       ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders
GROUP BY year
ORDER BY year;
/*
Result:
2014 | 969 orders | $484,247.45 | $499.74 avg
2015 | 1,038 ord.  | $470,532.48 | $453.31 avg
2016 | 1,315 ord.  | $609,205.66 | $463.27 avg
2017 | 1,687 ord.  | $733,215.24 | $434.63 avg
→ Revenue grew 51% from 2014 to 2017.
*/

-- Top 5 customers by spending
SELECT c.customer_id,
       c.customer_name,
       c.region,
       COUNT(DISTINCT o.order_id)         AS order_count,
       ROUND(SUM(o.total_amount), 2)      AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 5;
/*
Result:
SM-20320|Sean Miller|South|5|$25,043.05
TC-20980|Tamara Chand|West|4|$19,052.22
RB-19360|Raymond Buch|East|5|$15,117.34
TA-21385|Tom Ashbrook|East|6|$14,595.62
AB-10105|Adrian Barton|West|5|$14,473.58
*/

-- Bottom 5 customers by spending (lowest active)
SELECT c.customer_id,
       c.customer_name,
       c.region,
       COUNT(DISTINCT o.order_id)         AS order_count,
       ROUND(SUM(o.total_amount), 2)      AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
HAVING total_spent > 0
ORDER BY total_spent ASC
LIMIT 5;
/*
Result: Thais Sissman (West) $4.83, Lela Donovan (Central) $5.30, ...
*/

-- Top 10 products by sales revenue
SELECT p.product_id,
       p.product_name,
       p.category,
       ROUND(SUM(oi.sales), 2)  AS total_sales,
       SUM(oi.quantity)         AS total_units_sold,
       ROUND(SUM(oi.profit), 2) AS total_profit
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id
ORDER BY total_sales DESC
LIMIT 10;
/*
Result:
#1 Canon imageCLASS 2200 Advanced Copier | Technology | $61,599.83
#2 Fellowes PB500 Electric Punch | Office Supp. | $27,453.38
#3 Cisco TelePresence System EX90 | Technology | $22,638.48
*/

-- Top 10 products by units sold (quantity)
SELECT p.product_name,
       p.category,
       SUM(oi.quantity)         AS total_units_sold,
       ROUND(SUM(oi.sales), 2)  AS total_sales
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id
ORDER BY total_units_sold DESC
LIMIT 10;
/*
Result: Top-selling products by volume.
*/

-- Top 10 most profitable products
SELECT p.product_name,
       p.category,
       ROUND(SUM(oi.profit), 2) AS total_profit,
       ROUND(SUM(oi.sales), 2)  AS total_sales
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id
ORDER BY total_profit DESC
LIMIT 10;
/*
Result:
#1 Canon imageCLASS 2200 Advanced Copier | $25,199.94 profit
#2 Fellowes PB500 Electric Punch | $7,753.03 profit
#3 Hewlett Packard LaserJet 3310 Copier | $6,983.89 profit
*/

-- Top 10 biggest loss-making products
SELECT p.product_name,
       p.category,
       ROUND(SUM(oi.profit), 2) AS total_profit,
       ROUND(SUM(oi.sales), 2)  AS total_sales
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id
ORDER BY total_profit ASC
LIMIT 10;
/*
Result:
#1 Cubify CubeX 3D Printer Double Head Print | -$8,879.97 loss
#2 Lexmark MX611dhe Monochrome Laser Printer | -$4,589.97 loss
#3 Cubify CubeX 3D Printer Triple Head Print | -$3,839.99 loss
*/

-- Performance by region
SELECT c.region,
       COUNT(DISTINCT o.order_id)         AS order_count,
       ROUND(SUM(o.total_amount), 2)      AS total_sales,
       ROUND(AVG(o.total_amount), 2)      AS avg_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.region
ORDER BY total_sales DESC;
/*
Result:
West  | 1,594 orders | $764,634.49 | $479.70 avg
East  | 1,392 orders | $611,734.29 | $439.46 avg
Central| 1,196 orders | $518,800.07 | $433.78 avg
South | 827 orders   | $402,031.98 | $486.13 avg
*/

-- Performance by segment
SELECT c.segment,
       COUNT(DISTINCT c.customer_id)      AS customer_count,
       COUNT(DISTINCT o.order_id)         AS order_count,
       ROUND(SUM(o.total_amount), 2)      AS total_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.segment
ORDER BY total_sales DESC;
/*
Result:
Consumer    | 409 customers | 2,586 orders | $1,161,401.26
Corporate   | 236 customers | 1,514 orders | $706,146.42
Home Office | 148 customers | 909 orders   | $429,653.15
*/

-- Average discount by category
SELECT p.category,
       ROUND(AVG(oi.discount), 4) AS avg_discount,
       ROUND(SUM(oi.sales), 2)    AS total_sales,
       ROUND(SUM(oi.profit), 2)   AS total_profit
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY avg_discount DESC;
/*
Result:
Furniture     | 17.39% avg discount | $741,999.73 sales | $18,451.18 profit
Office Supp.  | 15.73% avg discount | $719,046.85 sales | $122,490.13 profit
Technology    | 13.23% avg discount | $836,154.06 sales | $145,455.31 profit
*/

-- Sub-categories with average line total > $300
SELECT p.category,
       p.sub_category,
       ROUND(AVG(oi.sales), 2)    AS avg_line_total,
       ROUND(SUM(oi.sales), 2)    AS total_sales,
       COUNT(*)                   AS item_count
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.sub_category
HAVING avg_line_total > 300
ORDER BY avg_line_total DESC;
/*
Result:
Copiers    | $2,198.94 avg | $149,528.01 total | 68 items
Machines   | $1,645.55 avg | $189,238.64 total | 115 items
Tables     | $648.79 avg   | $206,965.55 total | 319 items
Chairs     | $532.33 avg   | $328,449.08 total | 617 items
Bookcases  | $503.86 avg   | $114,879.98 total | 228 items
Phones     | $371.21 avg   | $330,007.10 total | 889 items
*/

-- Order size distribution (number of items per order)
SELECT items_count, COUNT(*) AS order_count
FROM (
    SELECT order_id, SUM(quantity) AS items_count
    FROM order_items
    GROUP BY order_id
)
GROUP BY items_count
ORDER BY items_count;
/*
Result: Most orders have 2-7 items.
1 item=235, 2=618, 3=636, 4=433, 5=491, 6=346, 7=361, 8=292, 9=255, 10=203...
*/

-- Overall order statistics
SELECT ROUND(MIN(total_amount), 2) AS min_order,
       ROUND(MAX(total_amount), 2) AS max_order,
       ROUND(AVG(total_amount), 2) AS avg_order,
       COUNT(*)                    AS total_orders,
       ROUND(SUM(total_amount), 2) AS total_revenue
FROM orders;
/*
Result: Min=$0.56, Max=$23,661.23, Avg=$458.61, Total=5,009, Revenue=$2,297,200.83
*/
