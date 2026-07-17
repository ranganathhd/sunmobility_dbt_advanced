-- dim_vehicles.sql
-- dimension table for vehicles

{{
    config(
        materialized = 'table'
    )
}}

SELECT
    vehicle_id,
    vehicle_no,
    customer_id,
    customer_type,
    city,
    state,
    vehicle_type,
    registered_date,
    status
FROM {{ ref('stg_vehicles') }}