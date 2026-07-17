USE ROLE ACCOUNTADMIN;
USE DATABASE SUNMOBILITY_ADVANCED_DB;
USE SCHEMA DBT_DEV_DBT_MARTS;

-- MV 1: Swap summary by station
CREATE OR REPLACE MATERIALIZED VIEW mv_swap_summary_by_station AS
SELECT
    station_id,
    station_name,
    region,
    station_city,
    COUNT(swap_id)                                       AS total_swaps,
    SUM(amount)                                          AS total_revenue,
    AVG(amount)                                          AS avg_swap_amount,
    COUNT(CASE WHEN swap_status = 'SUCCESS' THEN 1 END)  AS successful_swaps,
    COUNT(CASE WHEN swap_status = 'FAILED'  THEN 1 END)  AS failed_swaps,
    COUNT(CASE WHEN customer_type = 'RETAIL' THEN 1 END) AS retail_swaps,
    COUNT(CASE WHEN customer_type = 'FLEET'  THEN 1 END) AS fleet_swaps
FROM fct_swaps
GROUP BY station_id, station_name, region, station_city;

-- MV 2: Revenue by region and month
-- removed COUNT(DISTINCT) -- not supported in Snowflake MV
CREATE OR REPLACE MATERIALIZED VIEW mv_revenue_by_region_month AS
SELECT
    region,
    swap_year,
    swap_month,
    COUNT(swap_id)   AS total_swaps,
    SUM(amount)      AS total_revenue,
    AVG(amount)      AS avg_amount
FROM fct_swaps
WHERE swap_status = 'SUCCESS'
GROUP BY region, swap_year, swap_month;

-- verify both MVs created
SHOW MATERIALIZED VIEWS;

-- query
SELECT * FROM mv_swap_summary_by_station ORDER BY total_revenue DESC;
SELECT * FROM mv_revenue_by_region_month  ORDER BY swap_year, swap_month;