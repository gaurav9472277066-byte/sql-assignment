# SQL Assignment – Sales Data Analysis

## Overview

Complete SQL analysis of the **Sample Superstore** dataset — a US retail sales dataset with **9,994 order line items**, **793 customers**, **1,862 products**, and **5,009 orders** across 4 years (2014–2017).

This project covers the full SQL workflow: schema design → data loading → filtering → aggregation → joins → advanced analytics.

---

## Dataset

**File:** `data/Sample - Superstore.csv` (2.3 MB, 9,994 rows)

The dataset contains retail orders with customer details, product information, shipping modes, sales, discounts, and profits.

### Tables (Normalized Schema)

| Table | Rows | Primary Key | Foreign Keys |
|-------|------|-------------|--------------|
| `customers` | 793 | `customer_id` | — |
| `products` | 1,862 | `product_id` | — |
| `orders` | 5,009 | `order_id` | `customer_id` → customers |
| `order_items` | 9,994 | `row_id` | `order_id` → orders, `product_id` → products |

### Indexes Created

| Table | Index | Column(s) |
|-------|-------|-----------|
| customers | `idx_customers_region` | `region` |
| products | `idx_products_category` | `category` |
| orders | `idx_orders_customer` | `customer_id` |
| orders | `idx_orders_date` | `order_date` |
| order_items | `idx_order_items_order` | `order_id` |
| order_items | `idx_order_items_product` | `product_id` |

---

## Setup Instructions

### Option 1: Using pre-loaded setup script (fastest)

```bash
sqlite3 sales.db < setup.sql
```

### Option 2: Import from CSV directly

```bash
# 1. Create tables
sqlite3 sales.db < setup.sql

# 2. Import from CSV
sqlite3 sales.db ".mode csv" ".headers on" ".import data/Sample-Superstore.csv temp_import"

# 3. Transform into normalized tables
sqlite3 sales.db < import_csv.sql
```

Then run any section:

```bash
sqlite3 sales.db < Section_A/basic_queries.sql
sqlite3 sales.db < Section_B/filtering_queries.sql
sqlite3 sales.db < Section_C/aggregation_queries.sql
sqlite3 sales.db < Section_D/joins_queries.sql
sqlite3 sales.db < Section_E/advanced_queries.sql
```

---

## Key Analysis Insights

###  Revenue Trends

| Year | Orders | Revenue | Avg Order Value |
|------|--------|---------|-----------------|
| 2014 | 969 | $484,247.45 | $499.74 |
| 2015 | 1,038 | $470,532.48 | $453.31 |
| 2016 | 1,315 | $609,205.66 | $463.27 |
| 2017 | 1,687 | $733,215.24 | $434.63 |

**Insight:** Revenue grew **51%** from $484K (2014) to $733K (2017), driven by increasing order volume. However, average order value declined ~13%, suggesting more but smaller orders.

###  Category Performance

| Category | Revenue | Profit | Margin | Avg Discount |
|----------|---------|--------|--------|-------------|
| **Technology** | **$836,154** | **$145,455** | **17.4%** | 13.2% |
| Furniture | $741,999 | $18,451 | 2.5% | 17.4% |
| Office Supplies | $719,047 | $122,490 | 17.0% | 15.7% |

**Insight:** Technology is the most profitable category despite lower discounting. Furniture has razor-thin margins (2.5%) and the highest discount rate.

###  Regional Performance

| Region | Orders | Revenue | Avg Order Value |
|--------|--------|---------|-----------------|
| **West** | 1,594 | **$764,634** | $479.70 |
| East | 1,392 | $611,734 | $439.46 |
| Central | 1,196 | $518,800 | $433.78 |
| South | 827 | $402,032 | $486.13 |

**Insight:** West leads in revenue. South has the highest average order value but fewest orders — growth opportunity.

###  Top Customers

| Customer | Region | Orders | Total Spent |
|----------|--------|--------|-------------|
| Sean Miller | South | 5 | **$25,043** |
| Tamara Chand | West | 4 | $19,052 |
| Raymond Buch | East | 5 | $15,117 |
| Tom Ashbrook | East | 6 | $14,596 |
| Adrian Barton | West | 5 | $14,474 |

###  Shipping Analysis

- **59.8%** of orders use Standard Class (2,994 orders)
- Average shipping time: **4 days**
- Same Day: 264 orders (5.3%)
- No orders take longer than 7 days

###  Loss Analysis

- **1,871 items (18.7%)** sold at a loss
- Average loss per item: **-$83.45**
- Biggest loss: Cubify CubeX 3D Printer (-$8,880 across all sales)
- High discounts (≥40%) almost always result in negative profit

###  Data Quality

-  **No duplicate customers** — all 793 names are unique
-  **30+ duplicate products** — e.g., "Easy-staple paper" has 8 different product IDs, "Staple envelope" has 10+ entries
-  **8 duplicate order line items** — same order+product appears twice
-  **No orphan records** — all foreign key relationships are valid
-  **All order totals match** — no discrepancies between order total and item sums

---

## Query Sections

| Section | File | Queries | Topics |
|---------|------|---------|--------|
| **A – Basics** | `Section_A/basic_queries.sql` | 15 | Schema, sample data, row counts, constraints |
| **B – Filtering** | `Section_B/filtering_queries.sql` | 23 | WHERE, BETWEEN, LIKE, date range, EXPLAIN |
| **C – Aggregation** | `Section_C/aggregation_queries.sql` | 20 | GROUP BY, COUNT, SUM, AVG, MAX, MIN, HAVING |
| **D – Joins** | `Section_D/joins_queries.sql` | 15 | INNER JOIN, LEFT JOIN, 4-way join, validation |
| **E – Advanced** | `Section_E/advanced_queries.sql` | 17 | CASE, CTE, duplicate detection, transactions |

### Total: **90 SQL statements**

Each file includes query results as comments for reference.

---

## Folder Structure

```
sql-assignment/
├── data/
│   └── Sample - Superstore.csv    # Raw source data (2.3 MB)
├── Section_A/
│   └── basic_queries.sql          # Schema exploration & validation
├── Section_B/
│   └── filtering_queries.sql      # WHERE clauses & optimization
├── Section_C/
│   └── aggregation_queries.sql    # GROUP BY & aggregate functions
├── Section_D/
│   └── joins_queries.sql          # INNER & LEFT joins
├── Section_E/
│   └── advanced_queries.sql       # CASE, duplicates, transactions
├── setup.sql                      # Table creation, indexes, data loading
├── import_csv.sql                 # CSV import script (alternative load)
└── README.md                      # This file
```

---

## File Size Reference

| File | Size | Contents |
|------|------|----------|
| `setup.sql` | ~600 KB | CREATE TABLE + INSERT statements (all data) |
| `import_csv.sql` | ~3.5 KB | CSV → normalized tables transformer |
| `Section_*/*.sql` | ~30 KB total | 90 analytical queries with results |
| `data/Sample - Superstore.csv` | ~2.3 MB | Raw comma-separated source data |

---

## Requirements Covered

| # | Requirement | Status |
|---|-------------|--------|
| 1 | Load dataset into SQL database |  setup.sql + import_csv.sql |
| 2 | Explore table schema & sample data |  Section A |
| 3 | WHERE filters (region, category, date, sales) |  Section B (23 queries) |
| 4 | GROUP BY aggregations |  Section C (20 queries) |
| 5 | Sort & limit (top products/categories) |  Sections B & C |
| 6 | Monthly trends |  Section C |
| 6 | Top customers |  Sections C & D |
| 6 | Duplicate detection |  Section E |
| 7 | Data validation (row counts, quality) |  Sections A & D |
| 8 | SQL scripts + results + insights |  All sections + README |
| 9 | GitHub-ready folder structure | Clean hierarchy |
