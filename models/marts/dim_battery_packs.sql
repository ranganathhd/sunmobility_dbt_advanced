-- dim_battery_packs.sql
-- dimension table for battery packs
-- includes health percentage for monitoring

{{
    config(
        materialized = 'table'
    )
}}

SELECT
    battery_id,
    battery_code,
    capacity_kwh,
    manufacture_date,
    manufacturer,
    health_percentage,
    status,
    cycle_count,
    station_id,
    last_charged_at
FROM {{ ref('stg_battery_packs') }}