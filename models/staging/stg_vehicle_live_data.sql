-- stg_vehicle_live_data.sql
-- cleans and standardizes processed vehicle live data
-- GPS coordinates and battery level every 10 minutes

{{
    config(
        materialized = 'view'
    )
}}

SELECT
    record_id,
    vehicle_id,
    latitude::FLOAT             AS latitude,
    longitude::FLOAT            AS longitude,
    battery_level::FLOAT        AS battery_level,
    speed_kmph::FLOAT           AS speed_kmph,
    UPPER(TRIM(ignition_status)) AS ignition_status,
    recorded_at::TIMESTAMP      AS recorded_at,
    processed_at::TIMESTAMP     AS processed_at
FROM {{ source('raw', 'vehicle_live_data_processed') }}
WHERE record_id IS NOT NULL