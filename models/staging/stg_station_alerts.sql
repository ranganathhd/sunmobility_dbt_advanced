-- stg_station_alerts.sql
-- cleans and standardizes processed station alerts

{{
    config(
        materialized = 'view'
    )
}}

SELECT
    alert_id,
    station_id,
    dock_id,
    UPPER(TRIM(alert_type))    AS alert_type,
    UPPER(TRIM(severity))      AS severity,
    TRIM(alert_message)        AS alert_message,
    triggered_at::TIMESTAMP    AS triggered_at,
    resolved_at::TIMESTAMP     AS resolved_at,
    UPPER(TRIM(status))        AS status,
    processed_at::TIMESTAMP    AS processed_at
FROM {{ source('raw', 'station_alerts_processed') }}
WHERE alert_id IS NOT NULL