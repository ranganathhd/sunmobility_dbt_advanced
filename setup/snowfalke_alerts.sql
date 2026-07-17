USE ROLE ACCOUNTADMIN;
USE DATABASE SUNMOBILITY_ADVANCED_DB;
USE SCHEMA DBT_DEV_DBT_MARTS;

-- ============================================
-- Alert 1: Critical battery alerts detected
-- runs every 10 minutes
-- triggers if any CRITICAL battery alert is open
-- ============================================
CREATE OR REPLACE ALERT critical_battery_alert
    WAREHOUSE = COMPUTE_WH
    SCHEDULE  = '10 MINUTE'
IF (EXISTS (
    SELECT 1
    FROM fct_alerts
    WHERE severity    = 'CRITICAL'
    AND   status      = 'OPEN'
    AND   alert_source = 'BATTERY'
    AND   triggered_at >= DATEADD(minute, -10, CURRENT_TIMESTAMP)
))
THEN
    CALL SYSTEM$SEND_SNOWFLAKE_NOTIFICATION(
        SNOWFLAKE.NOTIFICATION.TEXT_PLAIN(
            CONCAT(
                'CRITICAL BATTERY ALERT detected at ',
                CURRENT_TIMESTAMP::VARCHAR,
                '. Please check fct_alerts table immediately.'
            )
        ),
        SNOWFLAKE.NOTIFICATION.INTEGRATION('email_notification')
    );

-- ============================================
-- Alert 2: Station offline detected
-- runs every 10 minutes
-- triggers if any station goes offline
-- ============================================
CREATE OR REPLACE ALERT station_offline_alert
    WAREHOUSE = COMPUTE_WH
    SCHEDULE  = '10 MINUTE'
IF (EXISTS (
    SELECT 1
    FROM fct_alerts
    WHERE alert_type  LIKE '%offline%'
    AND   status      = 'OPEN'
    AND   triggered_at >= DATEADD(minute, -10, CURRENT_TIMESTAMP)
))
THEN
    CALL SYSTEM$SEND_SNOWFLAKE_NOTIFICATION(
        SNOWFLAKE.NOTIFICATION.TEXT_PLAIN(
            CONCAT(
                'STATION OFFLINE ALERT at ',
                CURRENT_TIMESTAMP::VARCHAR,
                '. Check fct_alerts for details.'
            )
        ),
        SNOWFLAKE.NOTIFICATION.INTEGRATION('email_notification')
    );

-- resume both alerts
ALTER ALERT critical_battery_alert RESUME;
ALTER ALERT station_offline_alert  RESUME;

-- verify alerts created and running
SHOW ALERTS;