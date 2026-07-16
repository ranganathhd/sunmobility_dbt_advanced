USE ROLE ACCOUNTADMIN;
USE DATABASE SUNMOBILITY_ADVANCED_DB;
USE SCHEMA RAW_DATA;

-- ============================================
-- Real time table streams
-- APPEND_ONLY = TRUE — only tracks new inserts
-- Snowpipe only inserts — never updates
-- ============================================

-- stream on swap_records — tracks new swaps every 10 minutes
CREATE OR REPLACE STREAM swap_records_stream
    ON TABLE swap_records
    APPEND_ONLY = TRUE;

-- stream on station_alerts — tracks new alerts every 10 minutes
CREATE OR REPLACE STREAM station_alerts_stream
    ON TABLE station_alerts
    APPEND_ONLY = TRUE;

-- stream on battery_alerts — tracks new alerts every 10 minutes
CREATE OR REPLACE STREAM battery_alerts_stream
    ON TABLE battery_alerts
    APPEND_ONLY = TRUE;

-- stream on vehicle_live_data — tracks new GPS data every 10 minutes
CREATE OR REPLACE STREAM vehicle_live_data_stream
    ON TABLE vehicle_live_data
    APPEND_ONLY = TRUE;

-- ============================================
-- Master table streams
-- APPEND_ONLY = FALSE — tracks inserts AND updates
-- Master data gets updated — need to capture changes
-- ============================================

-- stream on stations — tracks status changes, capacity changes
CREATE OR REPLACE STREAM stations_stream
    ON TABLE stations
    APPEND_ONLY = FALSE;

-- stream on retail_customers — tracks plan changes, status changes
CREATE OR REPLACE STREAM retail_customers_stream
    ON TABLE retail_customers
    APPEND_ONLY = FALSE;

-- stream on fleet_customers — tracks subscription and balance changes
CREATE OR REPLACE STREAM fleet_customers_stream
    ON TABLE fleet_customers
    APPEND_ONLY = FALSE;

-- verify all 7 streams created
SHOW STREAMS;


--------------created processed table ------------------------------

-- processed table for swap records
CREATE OR REPLACE TABLE swap_records_processed (
    swap_id        VARCHAR(10),
    customer_id    VARCHAR(10),
    customer_type  VARCHAR(20),
    vehicle_id     VARCHAR(10),
    station_id     VARCHAR(10),
    dock_id        VARCHAR(10),
    battery_out    VARCHAR(10),
    battery_in     VARCHAR(10),
    swap_date      DATE,
    swap_time      TIME,
    operator_id    VARCHAR(10),
    amount         FLOAT,
    payment_type   VARCHAR(20),
    payment_status VARCHAR(20),
    swap_status    VARCHAR(20),
    failure_reason VARCHAR(100),
    processed_at   TIMESTAMP
);

-- processed table for station alerts
CREATE OR REPLACE TABLE station_alerts_processed (
    alert_id      VARCHAR(15),
    station_id    VARCHAR(10),
    dock_id       VARCHAR(10),
    alert_type    VARCHAR(50),
    severity      VARCHAR(20),
    alert_message VARCHAR(200),
    triggered_at  TIMESTAMP,
    resolved_at   TIMESTAMP,
    status        VARCHAR(20),
    processed_at  TIMESTAMP
);

-- processed table for battery alerts
CREATE OR REPLACE TABLE battery_alerts_processed (
    alert_id      VARCHAR(15),
    battery_id    VARCHAR(10),
    station_id    VARCHAR(10),
    alert_type    VARCHAR(50),
    severity      VARCHAR(20),
    alert_message VARCHAR(200),
    battery_health FLOAT,
    triggered_at  TIMESTAMP,
    resolved_at   TIMESTAMP,
    status        VARCHAR(20),
    processed_at  TIMESTAMP
);

-- processed table for vehicle live data
CREATE OR REPLACE TABLE vehicle_live_data_processed (
    record_id      VARCHAR(15),
    vehicle_id     VARCHAR(10),
    latitude       FLOAT,
    longitude      FLOAT,
    battery_level  FLOAT,
    speed_kmph     FLOAT,
    ignition_status VARCHAR(10),
    recorded_at    TIMESTAMP,
    processed_at   TIMESTAMP
);

------------------snowflake task --------------------------------------

USE ROLE ACCOUNTADMIN;
USE DATABASE SUNMOBILITY_ADVANCED_DB;
USE SCHEMA RAW_DATA;

-- ============================================
-- Task 1: Process swap records
-- runs every 10 minutes in Indian timezone
-- ============================================
CREATE OR REPLACE TASK process_swap_records_task
    WAREHOUSE = COMPUTE_WH
    SCHEDULE  = 'USING CRON */10 * * * * Asia/Kolkata'
WHEN
    SYSTEM$STREAM_HAS_DATA('swap_records_stream')
AS
    INSERT INTO swap_records_processed
    SELECT
        swap_id,
        customer_id,
        customer_type,
        vehicle_id,
        station_id,
        dock_id,
        battery_out,
        battery_in,
        swap_date,
        swap_time,
        operator_id,
        amount,
        payment_type,
        payment_status,
        swap_status,
        failure_reason,
        CURRENT_TIMESTAMP AS processed_at
    FROM swap_records_stream
    WHERE METADATA$ACTION = 'INSERT';

-- ============================================
-- Task 2: Process station alerts
-- ============================================
CREATE OR REPLACE TASK process_station_alerts_task
    WAREHOUSE = COMPUTE_WH
    SCHEDULE  = 'USING CRON */10 * * * * Asia/Kolkata'
WHEN
    SYSTEM$STREAM_HAS_DATA('station_alerts_stream')
AS
    INSERT INTO station_alerts_processed
    SELECT
        alert_id,
        station_id,
        dock_id,
        alert_type,
        severity,
        alert_message,
        triggered_at,
        resolved_at,
        status,
        CURRENT_TIMESTAMP AS processed_at
    FROM station_alerts_stream
    WHERE METADATA$ACTION = 'INSERT';

-- ============================================
-- Task 3: Process battery alerts
-- ============================================
CREATE OR REPLACE TASK process_battery_alerts_task
    WAREHOUSE = COMPUTE_WH
    SCHEDULE  = 'USING CRON */10 * * * * Asia/Kolkata'
WHEN
    SYSTEM$STREAM_HAS_DATA('battery_alerts_stream')
AS
    INSERT INTO battery_alerts_processed
    SELECT
        alert_id,
        battery_id,
        station_id,
        alert_type,
        severity,
        alert_message,
        battery_health,
        triggered_at,
        resolved_at,
        status,
        CURRENT_TIMESTAMP AS processed_at
    FROM battery_alerts_stream
    WHERE METADATA$ACTION = 'INSERT';

-- ============================================
-- Task 4: Process vehicle live data
-- ============================================
CREATE OR REPLACE TASK process_vehicle_live_data_task
    WAREHOUSE = COMPUTE_WH
    SCHEDULE  = 'USING CRON */10 * * * * Asia/Kolkata'
WHEN
    SYSTEM$STREAM_HAS_DATA('vehicle_live_data_stream')
AS
    INSERT INTO vehicle_live_data_processed
    SELECT
        record_id,
        vehicle_id,
        latitude,
        longitude,
        battery_level,
        speed_kmph,
        ignition_status,
        recorded_at,
        CURRENT_TIMESTAMP AS processed_at
    FROM vehicle_live_data_stream
    WHERE METADATA$ACTION = 'INSERT';

-- ============================================
-- Resume all tasks
-- tasks are suspended by default when created
-- ============================================
ALTER TASK process_swap_records_task      RESUME;
ALTER TASK process_station_alerts_task    RESUME;
ALTER TASK process_battery_alerts_task    RESUME;
ALTER TASK process_vehicle_live_data_task RESUME;

-- verify all tasks created and running
SHOW TASKS;

-- check processed tables are getting data
SELECT 'swap_records_processed'      AS table_name, COUNT(*) AS row_count FROM swap_records_processed
UNION ALL
SELECT 'station_alerts_processed'    AS table_name, COUNT(*) AS row_count FROM station_alerts_processed
UNION ALL
SELECT 'battery_alerts_processed'    AS table_name, COUNT(*) AS row_count FROM battery_alerts_processed
UNION ALL
SELECT 'vehicle_live_data_processed' AS table_name, COUNT(*) AS row_count FROM vehicle_live_data_processed;




-- manually execute tasks to test immediately
-- without waiting for cron schedule
EXECUTE TASK process_swap_records_task;
EXECUTE TASK process_station_alerts_task;
EXECUTE TASK process_battery_alerts_task;
EXECUTE TASK process_vehicle_live_data_task;