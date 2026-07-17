USE ROLE ACCOUNTADMIN;
USE DATABASE SUNMOBILITY_ADVANCED_DB;
USE SCHEMA DBT_DEV_DBT_MARTS;

-- ============================================
-- Add clustering key to fct_swaps
-- analysts most commonly filter by swap_date
-- and customer_type — cluster by these
-- ============================================
ALTER TABLE fct_swaps
    CLUSTER BY (swap_date, customer_type, region);

-- check clustering information
SELECT SYSTEM$CLUSTERING_INFORMATION('fct_swaps');

-- ============================================
-- Add clustering key to fct_vehicle_tracking
-- analysts filter by recorded_at and customer_type
-- ============================================
ALTER TABLE fct_vehicle_tracking
    CLUSTER BY (recorded_at, customer_type);

-- check clustering information
SELECT SYSTEM$CLUSTERING_INFORMATION('fct_vehicle_tracking');

-- ============================================
-- Add clustering key to fct_alerts
-- analysts filter by triggered_at and severity
-- ============================================
ALTER TABLE fct_alerts
    CLUSTER BY (triggered_at, severity);

-- ============================================
-- Test query performance after clustering
-- ============================================
SELECT
    region,
    customer_type,
    COUNT(swap_id)  AS total_swaps,
    SUM(amount)     AS total_revenue
FROM fct_swaps
WHERE swap_date    >= '2024-01-01'
AND   customer_type = 'FLEET'
GROUP BY region, customer_type
ORDER BY total_revenue DESC;