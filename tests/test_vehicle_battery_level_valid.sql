-- tests/test_vehicle_battery_level_valid.sql
-- Business rule: vehicle battery level must be between 0 and 100
-- Battery percentage cannot be negative or above 100

SELECT
    record_id,
    vehicle_id,
    battery_level
FROM {{ ref('stg_vehicle_live_data') }}
WHERE battery_level < 0
OR    battery_level > 100