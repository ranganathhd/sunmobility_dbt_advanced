-- stg_stations.sql
-- cleans and standardizes raw station data
-- includes GPS coordinates and dock information

-- stg_stations.sql
-- using clean_string macro instead of UPPER(TRIM())

{{
    config(
        materialized = 'view'
    )
}}

SELECT
    station_id,
    {{ clean_string('station_name') }}  AS station_name,
    {{ clean_string('city') }}          AS city,
    {{ clean_string('state') }}         AS state,
    {{ clean_string('region') }}        AS region,
    latitude,
    longitude,
    total_docks,
    active_docks,
    {{ clean_string('status') }}        AS status,
    onboarded_date::DATE                AS onboarded_date,
    last_online_date::DATE              AS last_online_date,
    {{ clean_string('manager_name') }}  AS manager_name,
    TRIM(manager_phone)                 AS manager_phone
FROM {{ source('raw', 'stations') }}
WHERE station_id IS NOT NULL