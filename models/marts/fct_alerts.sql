-- fct_alerts.sql
-- fact table for all alerts — station and battery
-- incremental model — only loads new records each run

{{
    config(
        materialized = 'incremental',
        unique_key   = 'alert_id',
        cluster_by   = ['triggered_at', 'severity', 'alert_source']
    )
}}

SELECT
    alert_id,
    alert_source,
    station_id,
    dock_id,
    battery_id,
    alert_type,
    severity,
    alert_message,
    battery_health,
    triggered_at,
    resolved_at,
    status,
    station_name,
    city,
    region,
    processed_at
FROM {{ ref('int_alerts_enriched') }}

{% if is_incremental() %}
    -- only load rows newer than what already exists in fct_alerts
    WHERE processed_at > (SELECT MAX(processed_at) FROM {{ this }})
{% endif %}