-- stg_retail_customers.sql
-- cleans and standardizes retail customer data

{{
    config(
        materialized = 'view'
    )
}}

SELECT
    customer_id,
    UPPER(TRIM(name))          AS customer_name,
    TRIM(phone)                AS phone,
    LOWER(TRIM(email))         AS email,
    UPPER(TRIM(city))          AS city,
    UPPER(TRIM(state))         AS state,
    vehicle_id,
    UPPER(TRIM(plan_type))     AS plan_type,
    registered_date::DATE      AS registered_date,
    UPPER(TRIM(status))        AS status
FROM {{ source('raw', 'retail_customers') }}
WHERE customer_id IS NOT NULL