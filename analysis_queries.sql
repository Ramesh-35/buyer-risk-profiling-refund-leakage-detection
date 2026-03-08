-- Buyer Risk Profiling & Refund Leakage Detection
-- Key SQL Logic Used in the Analysis

-- 1. Clean transaction dataset
SELECT *
FROM master_transactions
WHERE customerid IS NOT NULL;

-- 2. Identify refund transactions
SELECT *
FROM master_transactions
WHERE quantity < 0;

-- 3. Buyer aggregation
SELECT
    customerid,
    COUNT(invoice) AS total_transactions,
    SUM(quantity * price) AS total_purchase_value,
    SUM(CASE
        WHEN quantity < 0 THEN quantity * price
        ELSE 0
    END) AS total_refund_value
FROM master_transactions
GROUP BY customerid;

-- 4. Calculate refund value ratio
SELECT
    customerid,
    ABS(total_refund_value) / total_purchase_value AS refund_value_ratio
FROM buyer_aggregation;

-- 5. Buyer risk scoring example
SELECT
    customerid,
    refund_value_ratio,
    CASE
        WHEN refund_value_ratio > 0.5 THEN 'Severe'
        WHEN refund_value_ratio > 0.3 THEN 'High'
        WHEN refund_value_ratio > 0.1 THEN 'Medium'
        ELSE 'Low'
    END AS risk_tier
FROM buyer_aggregation;
