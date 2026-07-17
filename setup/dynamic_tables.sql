USE ROLE ACCOUNTADMIN;
USE DATABASE SUNMOBILITY_ADVANCED_DB;
USE SCHEMA DBT_DEV_DBT_MARTS;

-- ============================================
-- Dynamic Table for vehicle tracking summary
-- shows latest battery status per vehicle
-- auto-refreshes every 10 minutes
-- ============================================
CREATE OR REPLACE DYNAMIC TABLE dt_vehicle_battery_status
    TARGET_LAG   = '10 minutes'
    WAREHOUSE    = COMPUTE_WH
AS
SELECT
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
FROM fct_vehicle_tracking
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY vehicle_id
    ORDER BY recorded_at DESC
) = 1;
-- QUALIFY ROW_NUMBER() = keeps only latest record per vehicle
-- So analysts always see current location and battery of each vehicle

-- ============================================
-- Dynamic Table for station alert summary
-- shows open alerts per station
-- auto-refreshes every 10 minutes
-- ============================================
CREATE OR REPLACE DYNAMIC TABLE dt_station_open_alerts
    TARGET_LAG   = '10 minutes'
    WAREHOUSE    = COMPUTE_WH
AS
SELECT
    station_id,
    station_name,
    region,
    city,
    COUNT(alert_id)                                         AS total_open_alerts,
    COUNT(CASE WHEN severity = 'CRITICAL' THEN 1 END)       AS critical_alerts,
    COUNT(CASE WHEN severity = 'HIGH'     THEN 1 END)       AS high_alerts,
    COUNT(CASE WHEN alert_source = 'BATTERY' THEN 1 END)    AS battery_alerts,
    COUNT(CASE WHEN alert_source = 'STATION' THEN 1 END)    AS station_alerts,
    MIN(triggered_at)                                       AS oldest_alert_time
FROM fct_alerts
WHERE status = 'OPEN'
GROUP BY station_id, station_name, region, city;

-- verify dynamic tables created
SHOW DYNAMIC TABLES;

-- query dynamic tables
SELECT * FROM dt_vehicle_battery_status LIMIT 10;
SELECT * FROM dt_station_open_alerts ORDER BY critical_alerts DESC;