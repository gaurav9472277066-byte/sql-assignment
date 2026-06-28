-- ============================================================
-- Section A – Basics
-- Description: Schema exploration, sample data, and validation
-- ============================================================

-- List all tables in the database
SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;
/*
Result:
customers
order_items
orders
products
sqlite_sequence
*/

-- Explore customers table schema
PRAGMA table_info(customers);
/*
Result:
cid|customer_id TEXT PK |customer_name TEXT NOT NULL|segment TEXT NOT NULL
|country TEXT NOT NULL|city TEXT NOT NULL|state TEXT NOT NULL|region TEXT NOT NULL
*/

-- Explore products table schema
PRAGMA table_info(products);
/*
Result:
cid|product_id TEXT PK|product_name TEXT NOT NULL|category TEXT NOT NULL|sub_category TEXT NOT NULL
*/

-- Explore orders table schema
PRAGMA table_info(orders);
/*
Result:
cid|order_id TEXT PK|customer_id TEXT FK|order_date TEXT NOT NULL
|ship_date TEXT NOT NULL|ship_mode TEXT NOT NULL|total_amount REAL NOT NULL
*/

-- Explore order_items table schema
PRAGMA table_info(order_items);
/*
Result:
cid|row_id INTEGER PK|order_id TEXT FK|product_id TEXT FK
|quantity INTEGER NOT NULL|sales REAL NOT NULL|discount REAL NOT NULL|profit REAL NOT NULL
*/

-- Sample data: customers
SELECT * FROM customers LIMIT 10;
/*
Result:
CG-12520|Claire Gute|Consumer|United States|Henderson|Kentucky|South
DV-13045|Darrin Van Huff|Corporate|United States|Los Angeles|California|West
SO-20335|Sean O'Donnell|Consumer|United States|Fort Lauderdale|Florida|South
BH-11710|Brosina Hoffman|Consumer|United States|Los Angeles|California|West
AA-10480|Andrew Allen|Consumer|United States|Concord|North Carolina|South
IM-15070|Irene Maddox|Consumer|United States|Seattle|Washington|West
HP-14815|Harold Pawlan|Home Office|United States|Fort Worth|Texas|Central
PK-19075|Pete Kriz|Consumer|United States|Madison|Wisconsin|Central
AG-10270|Alejandro Grove|Consumer|United States|West Jordan|Utah|West
ZD-21925|Zuschuss Donatelli|Consumer|United States|San Francisco|California|West
*/

-- Sample data: products
SELECT * FROM products LIMIT 10;
/*
Result:
FUR-BO-10001798|Bush Somerset Collection Bookcase|Furniture|Bookcases
FUR-CH-10000454|Hon Deluxe Fabric Upholstered Stacking Chairs, Rounded Back|Furniture|Chairs
OFF-LA-10000240|Self-Adhesive Address Labels for Typewriters by Universal|Office Supplies|Labels
FUR-TA-10000577|Bretford CR4500 Series Slim Rectangular Table|Furniture|Tables
OFF-ST-10000760|Eldon Fold 'N Roll Cart System|Office Supplies|Storage
FUR-FU-10001487|Eldon Expressions Wood and Plastic Desk Accessories, Cherry Wood|Furniture|Furnishings
OFF-AR-10002833|Newell 322|Office Supplies|Art
TEC-PH-10002275|Mitel 5320 IP Phone VoIP phone|Technology|Phones
OFF-BI-10003910|DXL Angle-View Binders with Locking Rings by Samsill|Office Supplies|Binders
OFF-AP-10002892|Belkin F5C206VTEL 6 Outlet Surge|Office Supplies|Appliances
*/

-- Sample data: orders
SELECT * FROM orders LIMIT 10;
/*
Result:
CA-2016-152156|CG-12520|2016-11-08|2016-11-11|Second Class|993.9
CA-2016-138688|DV-13045|2016-06-12|2016-06-16|Second Class|14.62
US-2015-108966|SO-20335|2015-10-11|2015-10-18|Standard Class|979.95
CA-2014-115812|BH-11710|2014-06-09|2014-06-14|Standard Class|3714.3
CA-2017-114412|AA-10480|2017-04-15|2017-04-20|Standard Class|15.55
CA-2016-161389|IM-15070|2016-12-05|2016-12-10|Standard Class|407.98
US-2015-118983|HP-14815|2015-11-22|2015-11-26|Standard Class|71.35
CA-2014-105893|PK-19075|2014-11-11|2014-11-18|Standard Class|665.88
CA-2014-167164|AG-10270|2014-05-13|2014-05-15|Second Class|55.5
CA-2014-143336|ZD-21925|2014-08-27|2014-09-01|Second Class|244.76
*/

-- Sample data: order_items
SELECT * FROM order_items LIMIT 10;
/*
Result:
1|CA-2016-152156|FUR-BO-10001798|2|261.96|0.0|41.91
2|CA-2016-152156|FUR-CH-10000454|3|731.94|0.0|219.58
3|CA-2016-138688|OFF-LA-10000240|2|14.62|0.0|6.87
4|US-2015-108966|FUR-TA-10000577|5|957.58|0.45|-383.03
5|US-2015-108966|OFF-ST-10000760|2|22.37|0.2|2.52
6|CA-2014-115812|FUR-FU-10001487|7|48.86|0.0|14.17
7|CA-2014-115812|OFF-AR-10002833|4|7.28|0.0|1.97
8|CA-2014-115812|TEC-PH-10002275|6|907.15|0.2|90.72
9|CA-2014-115812|OFF-BI-10003910|3|18.5|0.2|5.78
10|CA-2014-115812|OFF-AP-10002892|5|114.9|0.0|34.47
*/

-- Row count validation
SELECT 'customers' AS tbl, COUNT(*) FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;
/*
Result: customers=793, products=1862, orders=5009, order_items=9994
*/

-- Distinct regions from customers
SELECT DISTINCT region FROM customers;
/*
Result: Central, East, South, West
*/

-- Distinct segments from customers
SELECT DISTINCT segment FROM customers;
/*
Result: Consumer, Corporate, Home Office
*/

-- Distinct categories from products
SELECT DISTINCT category FROM products;
/*
Result: Furniture, Office Supplies, Technology
*/

-- Distinct ship modes from orders
SELECT DISTINCT ship_mode FROM orders;
/*
Result: First Class, Same Day, Second Class, Standard Class
*/

-- Table constraint summary
SELECT 'customers' AS tbl, 'customer_id TEXT PK' AS constraints
UNION ALL
SELECT 'products', 'product_id TEXT PK'
UNION ALL
SELECT 'orders', 'order_id TEXT PK, customer_id TEXT FK → customers'
UNION ALL
SELECT 'order_items', 'row_id INTEGER PK, order_id TEXT FK → orders, product_id TEXT FK → products';
/*
Result:
customers|customer_id TEXT PK
products|product_id TEXT PK
orders|order_id TEXT PK, customer_id TEXT FK → customers
order_items|row_id INTEGER PK, order_id TEXT FK → orders, product_id TEXT FK → products
*/
