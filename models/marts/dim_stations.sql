-- dim_stations.sql
-- dimension table for swap stations
-- stores descriptive station information

{{
    config(
        materialized = 'table'
    )
}}

SELECT
    station_id,
    station_name,
    city,
    state,
    region,
    latitude,
    longitude,
    total_docks,
    active_docks,
    status,
    onboarded_date,
    last_online_date,
    manager_name,
    manager_phone
FROM {{ ref('stg_stations') }}