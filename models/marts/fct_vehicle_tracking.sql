-- fct_vehicle_tracking.sql
-- fact table for vehicle GPS and battery tracking
-- incremental model — 500 vehicles every 10 minutes
-- very large table — incremental is critical here

{{
    config(
        materialized = 'incremental',
        unique_key   = 'record_id',
        cluster_by   = ['recorded_at', 'customer_type']
    )
}}

SELECT
    record_id,
    vehicle_id,
    vehicle_no,
    vehicle_type,
    customer_id,
    customer_type,
    customer_name,
    latitude,
    longitude,
    battery_level,
    battery_status,
    speed_kmph,
    ignition_status,
    movement_status,
    recorded_at
FROM {{ ref('int_vehicle_tracking') }}

{% if is_incremental() %}
    -- only load rows newer than what already exists
    WHERE recorded_at > (SELECT MAX(recorded_at) FROM {{ this }})
{% endif %}