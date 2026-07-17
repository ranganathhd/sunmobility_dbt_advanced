-- int_swaps_enriched.sql
-- joins swap records with customers, stations, batteries
-- adds business logic for retail vs fleet billing

{{
    config(
        materialized = 'ephemeral'
    )
}}

SELECT
    s.swap_id,
    s.customer_id,
    s.customer_type,
    s.vehicle_id,
    s.station_id,
    s.dock_id,
    s.battery_out,
    s.battery_in,
    s.swap_date,
    s.swap_time,
    s.operator_id,
    s.amount,
    s.payment_type,
    s.payment_status,
    s.swap_status,
    s.failure_reason,
    s.processed_at,
    -- station details
    st.station_name,
    st.city          AS station_city,
    st.state         AS station_state,
    st.region,
    -- vehicle details
    v.vehicle_no,
    v.vehicle_type,
    -- customer details based on type
    CASE
        WHEN s.customer_type = 'RETAIL'
        THEN rc.customer_name
        ELSE fc.company_name
    END              AS customer_name,
    CASE
        WHEN s.customer_type = 'RETAIL'
        THEN rc.plan_type
        ELSE fc.subscription_plan
    END              AS plan_type,
    -- battery details
    b_out.battery_code    AS battery_out_code,
    b_out.health_percentage AS battery_out_health,
    b_in.battery_code     AS battery_in_code,
    b_in.health_percentage  AS battery_in_health,
    -- business logic
    CASE
        WHEN s.amount >= 150 THEN 'High Value'
        WHEN s.amount >= 100 THEN 'Medium Value'
        ELSE 'Low Value'
    END              AS amount_category,
    MONTH(s.swap_date) AS swap_month,
    YEAR(s.swap_date)  AS swap_year,
    DAYOFWEEK(s.swap_date) AS swap_day_of_week
FROM {{ ref('stg_swap_records') }}      s
JOIN {{ ref('stg_stations') }}          st   ON s.station_id  = st.station_id
JOIN {{ ref('stg_vehicles') }}          v    ON s.vehicle_id  = v.vehicle_id
JOIN {{ ref('stg_battery_packs') }}     b_out ON s.battery_out = b_out.battery_id
JOIN {{ ref('stg_battery_packs') }}     b_in  ON s.battery_in  = b_in.battery_id
LEFT JOIN {{ ref('stg_retail_customers') }} rc ON s.customer_id = rc.customer_id
                                               AND s.customer_type = 'RETAIL'
LEFT JOIN {{ ref('stg_fleet_customers') }}  fc ON s.customer_id = fc.fleet_id
                                               AND s.customer_type = 'FLEET'