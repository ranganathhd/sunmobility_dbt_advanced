-- int_alerts_enriched.sql
-- combines station alerts and battery alerts
-- enriches with station details

{{
    config(
        materialized = 'ephemeral'
    )
}}

-- station alerts enriched with station details
SELECT
    sa.alert_id,
    'STATION'              AS alert_source,
    sa.station_id,
    sa.dock_id,
    NULL                   AS battery_id,
    sa.alert_type,
    sa.severity,
    sa.alert_message,
    NULL                   AS battery_health,
    sa.triggered_at,
    {{ is_high_priority_alert('sa.severity') }} AS is_high_priority,

    sa.resolved_at,
    sa.status,
    sa.processed_at,
    -- station details
    st.station_name,
    st.city,
    st.region
FROM {{ ref('stg_station_alerts') }}    sa
JOIN {{ ref('stg_stations') }}          st ON sa.station_id = st.station_id

UNION ALL

-- battery alerts enriched with station details
SELECT
    ba.alert_id,
    'BATTERY'              AS alert_source,
    ba.station_id,
    NULL                   AS dock_id,
    ba.battery_id,
    ba.alert_type,
    ba.severity,
    ba.alert_message,
    {{ is_high_priority_alert('sa.severity') }} AS is_high_priority,
    ba.battery_health,
    ba.triggered_at,
    ba.resolved_at,
    ba.status,
    ba.processed_at,
    -- station details
    st.station_name,
    st.city,
    st.region
FROM {{ ref('stg_battery_alerts') }}    ba
JOIN {{ ref('stg_stations') }}          st ON ba.station_id = st.station_id