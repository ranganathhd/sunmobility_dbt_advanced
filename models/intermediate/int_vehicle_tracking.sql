-- int_vehicle_tracking.sql
-- joins vehicle live data with vehicle and customer details
-- adds battery status classification

{{
    config(
        materialized = 'ephemeral'
    )
}}

SELECT
    vl.record_id,
    vl.vehicle_id,
    vl.latitude,
    vl.longitude,
    vl.battery_level,
    vl.speed_kmph,
    vl.ignition_status,
    vl.recorded_at,
    -- vehicle details
    v.vehicle_no,
    v.vehicle_type,
    v.customer_id,
    v.customer_type,
    -- customer name based on type
    CASE
        WHEN v.customer_type = 'RETAIL'
        THEN rc.customer_name
        ELSE fc.company_name
    END              AS customer_name,
    -- battery status classification
    CASE
        WHEN vl.battery_level >= 80 THEN 'High'
        WHEN vl.battery_level >= 40 THEN 'Medium'
        WHEN vl.battery_level >= 20 THEN 'Low'
        ELSE 'Critical'
    END              AS battery_status,
    -- vehicle movement status
    CASE
        WHEN vl.speed_kmph > 0 AND vl.ignition_status = 'ON' THEN 'Moving'
        WHEN vl.speed_kmph = 0 AND vl.ignition_status = 'ON' THEN 'Idle'
        ELSE 'Parked'
    END              AS movement_status
FROM {{ ref('stg_vehicle_live_data') }}     vl
JOIN {{ ref('stg_vehicles') }}              v    ON vl.vehicle_id  = v.vehicle_id
LEFT JOIN {{ ref('stg_retail_customers') }} rc   ON v.customer_id  = rc.customer_id
                                                 AND v.customer_type = 'RETAIL'
LEFT JOIN {{ ref('stg_fleet_customers') }}  fc   ON v.customer_id  = fc.fleet_id
                                                 AND v.customer_type = 'FLEET'