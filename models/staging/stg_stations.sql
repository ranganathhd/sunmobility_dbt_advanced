-- stg_stations.sql
-- cleans and standardizes raw station data
-- includes GPS coordinates and dock information

{{
    config(
        materialized = 'view'
    )
}}

SELECT
    station_id,
    UPPER(TRIM(station_name))  AS station_name,
    UPPER(TRIM(city))          AS city,
    UPPER(TRIM(state))         AS state,
    UPPER(TRIM(region))        AS region,
    latitude,
    longitude,
    total_docks,
    active_docks,
    UPPER(TRIM(status))        AS status,
    onboarded_date::DATE       AS onboarded_date,
    last_online_date::DATE     AS last_online_date,
    UPPER(TRIM(manager_name))  AS manager_name,
    TRIM(manager_phone)        AS manager_phone
FROM {{ source('raw', 'stations') }}
WHERE station_id IS NOT NULL