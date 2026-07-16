-- stg_battery_packs.sql
-- cleans and standardizes battery pack data

{{
    config(
        materialized = 'view'
    )
}}

SELECT
    battery_id,
    UPPER(TRIM(battery_code))   AS battery_code,
    capacity_kwh::FLOAT         AS capacity_kwh,
    manufacture_date::DATE      AS manufacture_date,
    UPPER(TRIM(manufacturer))   AS manufacturer,
    health_percentage::FLOAT    AS health_percentage,
    UPPER(TRIM(status))         AS status,
    cycle_count::INT            AS cycle_count,
    station_id,
    last_charged_at::TIMESTAMP  AS last_charged_at
FROM {{ source('raw', 'battery_packs') }}
WHERE battery_id IS NOT NULL