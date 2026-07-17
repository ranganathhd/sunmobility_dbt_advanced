-- dim_retail_customers.sql
-- dimension table for retail customers

{{
    config(
        materialized = 'table'
    )
}}

SELECT
    customer_id,
    customer_name,
    phone,
    email,
    city,
    state,
    vehicle_id,
    plan_type,
    registered_date,
    status
FROM {{ ref('stg_retail_customers') }}