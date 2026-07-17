-- stations_snapshot.sql
-- tracks how station data changes over time
-- SCD Type 2 — keeps full history
-- useful for: station went offline, capacity changed, manager changed

{% snapshot stations_snapshot %}

{{
    config(
        target_schema = 'SNAPSHOTS',
        unique_key    = 'station_id',
        strategy      = 'check',
        check_cols    = ['status', 'capacity', 'active_docks', 'manager_name']
    )
}}

SELECT
    station_id,
    station_name,
    city,
    state,
    region,
    total_docks,
    active_docks,
    status,
    manager_name,
    manager_phone,
    onboarded_date,
    last_online_date
FROM {{ ref('stg_stations') }}

{% endsnapshot %}