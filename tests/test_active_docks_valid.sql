-- tests/test_active_docks_valid.sql
-- Business rule: active docks cannot exceed total docks
-- A station cannot have more working docks than total docks

SELECT
    station_id,
    active_docks,
    total_docks
FROM {{ ref('stg_stations') }}
WHERE active_docks > total_docks