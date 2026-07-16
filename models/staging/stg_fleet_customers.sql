-- stg_fleet_customers.sql
-- cleans and standardizes fleet customer data

{{
    config(
        materialized = 'view'
    )
}}

SELECT
    fleet_id,
    UPPER(TRIM(company_name))    AS company_name,
    UPPER(TRIM(contact_person))  AS contact_person,
    TRIM(phone)                  AS phone,
    LOWER(TRIM(email))           AS email,
    UPPER(TRIM(city))            AS city,
    UPPER(TRIM(state))           AS state,
    UPPER(TRIM(subscription_plan)) AS subscription_plan,
    monthly_deposit::FLOAT       AS monthly_deposit,
    current_balance::FLOAT       AS current_balance,
    vehicle_count::INT           AS vehicle_count,
    registered_date::DATE        AS registered_date,
    UPPER(TRIM(status))          AS status
FROM {{ source('raw', 'fleet_customers') }}
WHERE fleet_id IS NOT NULL