-- stg_vehicles.sql
-- cleans and standardizes vehicle data

{{
    config(
        materialized = 'view'
    )
}}

SELECT
    vehicle_id,
    UPPER(TRIM(vehicle_no))    AS vehicle_no,
    customer_id,
    UPPER(TRIM(customer_type)) AS customer_type,
    UPPER(TRIM(city))          AS city,
    UPPER(TRIM(state))         AS state,
    UPPER(TRIM(vehicle_type))  AS vehicle_type,
    registered_date::DATE      AS registered_date,
    UPPER(TRIM(status))        AS status
FROM {{ source('raw', 'vehicles') }}
WHERE vehicle_id IS NOT NULL