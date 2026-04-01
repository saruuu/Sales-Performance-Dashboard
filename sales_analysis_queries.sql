-- ============================================================
-- SALES PERFORMANCE ANALYSIS — PROJECT 1
-- Dataset: Sample Sales Data (2003–2005)
-- Tool: PostgreSQL
-- Author: Saru
-- ============================================================


-- ── SETUP ────────────────────────────────────────────────────

CREATE TABLE sales (
  ordernumber       INT,
  quantityordered   INT,
  priceeach         NUMERIC(10,2),
  orderlinenumber   INT,
  sales             NUMERIC(10,2),
  orderdate         VARCHAR(20),
  status            VARCHAR(20),
  qtr_id            INT,
  month_id          INT,
  year_id           INT,
  productline       VARCHAR(50),
  msrp              INT,
  productcode       VARCHAR(20),
  customername      VARCHAR(100),
  phone             VARCHAR(30),
  addressline1      VARCHAR(100),
  addressline2      VARCHAR(100),
  city              VARCHAR(50),
  state             VARCHAR(50),
  postalcode        VARCHAR(20),
  country           VARCHAR(50),
  territory         VARCHAR(20),
  contactlastname   VARCHAR(50),
  contactfirstname  VARCHAR(50),
  dealsize          VARCHAR(20)
);

COPY sales
FROM '/Users/saru/sales_data_sample.csv'
DELIMITER ','
CSV HEADER
ENCODING 'LATIN1';


-- ── Q1: REVENUE BY PRODUCT LINE ──────────────────────────────
-- Which product line generates the most revenue?

SELECT
  productline,
  ROUND(SUM(sales), 2)      AS total_revenue,
  COUNT(DISTINCT ordernumber) AS total_orders,
  ROUND(AVG(sales), 2)      AS avg_order_value
FROM sales
GROUP BY productline
ORDER BY total_revenue DESC;

-- Result: Classic Cars leads with $3.9M (39% of total revenue)


-- ── Q2: MONTHLY REVENUE TREND ────────────────────────────────
-- How do sales trend month by month across years?

SELECT
  year_id,
  month_id,
  ROUND(SUM(sales), 2) AS monthly_revenue,
  COUNT(DISTINCT ordernumber) AS orders
FROM sales
GROUP BY year_id, month_id
ORDER BY year_id, month_id;

-- Result: November is peak month every year (Q4 spike)
-- Note: 2005 data only goes to May — do not compare annual totals directly


-- ── Q3: REVENUE BY COUNTRY ───────────────────────────────────
-- Which countries and territories drive the most revenue?

SELECT
  country,
  territory,
  ROUND(SUM(sales), 2)      AS total_revenue,
  COUNT(DISTINCT ordernumber) AS total_orders,
  ROUND(
    SUM(sales) * 100.0 /
    SUM(SUM(sales)) OVER(), 2
  )                          AS revenue_pct
FROM sales
GROUP BY country, territory
ORDER BY total_revenue DESC
LIMIT 10;

-- Result: USA = 36.2%, Spain = 12.1%, France = 11.1%
-- EMEA territory combined exceeds USA


-- ── Q4: DEAL SIZE BREAKDOWN ──────────────────────────────────
-- How does revenue split across Small / Medium / Large deals?

SELECT
  dealsize,
  COUNT(*)                  AS num_orders,
  ROUND(SUM(sales), 2)   AS total_revenue,
  ROUND(AVG(sales), 2)   AS avg_sale,
  ROUND(MIN(sales), 2)   AS min_sale,
  ROUND(MAX(sales), 2)   AS max_sale
FROM sales
GROUP BY dealsize
ORDER BY total_revenue DESC;

-- Result: Medium deals = highest total revenue ($6.1M)
-- Large deals = highest avg value ($8,294) but only 157 orders


-- ── Q5: TOP 10 CUSTOMERS ─────────────────────────────────────
-- Who are the highest-value customers by total spend?

SELECT
  customername,
  country,
  ROUND(SUM(sales), 2)        AS total_spent,
  COUNT(DISTINCT ordernumber)  AS num_orders,
  ROUND(AVG(sales), 2)        AS avg_order_value
FROM sales
GROUP BY customername, country
ORDER BY total_spent DESC
LIMIT 10;

-- Result: Euro Shopping Channel (Spain) = $912K — top by wide margin
-- Top 2 customers = $1.57M = 15.6% of all revenue (concentration risk)


-- ── BONUS: YEARLY REVENUE SUMMARY ────────────────────────────

SELECT
  year_id,
  ROUND(SUM(sales), 2)        AS annual_revenue,
  COUNT(DISTINCT ordernumber)  AS total_orders,
  COUNT(DISTINCT customername) AS unique_customers
FROM sales
GROUP BY year_id
ORDER BY year_id;


-- ── BONUS: STATUS BREAKDOWN ──────────────────────────────────

SELECT
  status,
  COUNT(*)              AS num_orders,
  ROUND(SUM(sales), 2) AS total_value
FROM sales
GROUP BY status
ORDER BY num_orders DESC;
