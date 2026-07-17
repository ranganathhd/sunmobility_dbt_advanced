-- dim_fleet_customers.sql
-- dimension table for fleet customers

{{
    config(
        materialized = 'table'
    )
}}

SELECT
    fleet_id,
    company_name,
    contact_person,
    phone,
    email,
    city,
    state,
    subscription_plan,
    monthly_deposit,
    current_balance,
    vehicle_count,
    registered_date,
    status
FROM {{ ref('stg_fleet_customers') }}