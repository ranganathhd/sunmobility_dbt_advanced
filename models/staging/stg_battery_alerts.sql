-- stg_battery_alerts.sql
-- cleans and standardizes processed battery alerts

{{
    config(
        materialized = 'view'
    )
}}

SELECT
    alert_id,
    battery_id,
    station_id,
    UPPER(TRIM(alert_type))    AS alert_type,
    UPPER(TRIM(severity))      AS severity,
    TRIM(alert_message)        AS alert_message,
    battery_health::FLOAT      AS battery_health,
    triggered_at::TIMESTAMP    AS triggered_at,
    resolved_at::TIMESTAMP     AS resolved_at,
    UPPER(TRIM(status))        AS status,
    processed_at::TIMESTAMP    AS processed_at
FROM {{ source('raw', 'battery_alerts_processed') }}
WHERE alert_id IS NOT NULL