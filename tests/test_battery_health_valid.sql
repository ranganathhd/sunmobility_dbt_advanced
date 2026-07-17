-- tests/test_battery_health_valid.sql
-- Business rule: battery health must be between 0 and 100
-- Values outside this range are invalid

SELECT
    battery_id,
    health_percentage
FROM {{ ref('stg_battery_packs') }}
WHERE health_percentage < 0
OR    health_percentage > 100