-- ============================================================
-- CSV Import Script for Sample Superstore Data
-- ============================================================
-- Usage: sqlite3 sales.db < import_csv.sql
-- Note: Run setup.sql FIRST to create tables, then run this
--       script to load data from the CSV file.
-- ============================================================

-- Clear existing data (if any) before importing
DELETE FROM order_items;
DELETE FROM orders;
DELETE FROM products;
DELETE FROM customers;

-- Import using SQLite's .import command (meta-command, not SQL)
-- Run these in the sqlite3 CLI:
--
-- .mode csv
-- .headers on
-- .import data/Sample\ -\ Superstore.csv temp_import
--
-- Since .import is a dot-command, use this shell one-liner instead:
--   sqlite3 sales.db ".mode csv" ".headers on" ".import data/Sample-Superstore.csv temp_import"
--
-- Then run the transformation queries below.

-- ============================================================
-- Step 1: Create a staging table matching the CSV structure
-- ============================================================
DROP TABLE IF EXISTS temp_import;
CREATE TABLE temp_import (
    row_id        INTEGER,
    order_id      TEXT,
    order_date    TEXT,
    ship_date     TEXT,
    ship_mode     TEXT,
    customer_id   TEXT,
    customer_name TEXT,
    segment       TEXT,
    country       TEXT,
    city          TEXT,
    state         TEXT,
    postal_code   TEXT,
    region        TEXT,
    product_id    TEXT,
    category      TEXT,
    sub_category  TEXT,
    product_name  TEXT,
    sales         REAL,
    quantity      INTEGER,
    discount      REAL,
    profit        REAL
);

-- Note: After running .import, run the INSERT statements below
-- to populate the normalized tables from the staging table.

-- ============================================================
-- Step 2: Populate normalized tables from staging
-- ============================================================

-- Insert unique customers
INSERT OR IGNORE INTO customers (customer_id, customer_name, segment, country, city, state, region)
SELECT DISTINCT
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    region
FROM temp_import;

-- Insert unique products
INSERT OR IGNORE INTO products (product_id, product_name, category, sub_category)
SELECT DISTINCT
    product_id,
    product_name,
    category,
    sub_category
FROM temp_import;

-- Insert unique orders (aggregate order-level info)
INSERT OR IGNORE INTO orders (order_id, customer_id, order_date, ship_date, ship_mode, total_amount)
SELECT
    order_id,
    customer_id,
    date(substr(order_date, 7, 4) || '-' || substr(order_date, 1, 2) || '-' || substr(order_date, 4, 2)),
    date(substr(ship_date, 7, 4) || '-' || substr(ship_date, 1, 2) || '-' || substr(ship_date, 4, 2)),
    ship_mode,
    ROUND(SUM(sales), 2)
FROM temp_import
GROUP BY order_id, customer_id, order_date, ship_date, ship_mode;

-- Insert order line items
INSERT INTO order_items (order_id, product_id, quantity, sales, discount, profit)
SELECT
    order_id,
    product_id,
    quantity,
    sales,
    discount,
    profit
FROM temp_import;

-- Clean up staging table
DROP TABLE IF EXISTS temp_import;

-- ============================================================
-- Step 3: Verify the import
-- ============================================================
SELECT 'customers' AS tbl, COUNT(*) FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;
