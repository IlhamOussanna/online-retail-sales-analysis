--1. Create a Staging Table
CREATE TABLE stg_online_retail (
    invoice_no TEXT,
    stock_code TEXT,
    description TEXT,
    quantity TEXT,
    invoice_date TEXT,
    unit_price TEXT,
    customer_id TEXT,
    country TEXT
);

--2. Check how many missing Customer IDs
SELECT COUNT(*) 
FROM stg_online_retail
WHERE customer_id IS NULL OR customer_id = '';

--3. Check negative quantities
SELECT COUNT(*) 
FROM stg_online_retail
WHERE quantity::NUMERIC < 0;

--4. Check cancellations
SELECT COUNT(*) 
FROM stg_online_retail
WHERE invoice_no LIKE 'C%';

--5. Create Clean Analytical View
CREATE OR REPLACE VIEW v_retail_clean AS
SELECT
    invoice_no,
    stock_code,
    description,
    quantity::NUMERIC AS quantity,
    TO_TIMESTAMP(invoice_date, 'MM/DD/YYYY HH24:MI') AS invoice_timestamp,
    unit_price::NUMERIC AS unit_price,
    customer_id,
    country,
    (quantity::NUMERIC * unit_price::NUMERIC) AS line_revenue
FROM stg_online_retail
WHERE quantity::NUMERIC > 0
  AND unit_price::NUMERIC > 0
  AND invoice_no NOT LIKE 'C%';

