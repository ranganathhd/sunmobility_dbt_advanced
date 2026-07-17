-- fct_fleet_billing.sql
-- fact table for fleet customer monthly billing
-- shows swap usage vs subscription balance

{{
    config(
        materialized = 'table'
    )
}}

SELECT
    s.customer_id        AS fleet_id,
    s.customer_name      AS company_name,
    s.plan_type          AS subscription_plan,
    s.swap_year,
    s.swap_month,
    COUNT(s.swap_id)     AS total_swaps,
    SUM(s.amount)        AS total_amount,
    AVG(s.amount)        AS avg_swap_amount,
    COUNT(CASE WHEN s.swap_status = 'SUCCESS' THEN 1 END) AS successful_swaps,
    COUNT(CASE WHEN s.swap_status = 'FAILED'  THEN 1 END) AS failed_swaps,
    fc.monthly_deposit,
    fc.current_balance,
    -- remaining balance after swaps
    fc.current_balance - SUM(s.amount) AS remaining_balance
FROM {{ ref('int_swaps_enriched') }}     s
JOIN {{ ref('stg_fleet_customers') }}    fc ON s.customer_id = fc.fleet_id
WHERE s.customer_type = 'FLEET'
GROUP BY
    s.customer_id,
    s.customer_name,
    s.plan_type,
    s.swap_year,
    s.swap_month,
    fc.monthly_deposit,
    fc.current_balance