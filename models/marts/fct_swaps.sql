-- fct_swaps.sql
-- fact table for all swap transactions
-- incremental model — only loads new records each run

{{
    config(
        materialized = 'incremental',
        unique_key   = 'swap_id',
        cluster_by   = ['swap_date', 'region', 'customer_type']
    )
}}

SELECT
    swap_id,
    customer_id,
    customer_type,
    vehicle_id,
    station_id,
    dock_id,
    battery_out,
    battery_in,
    swap_date,
    swap_time,
    operator_id,
    amount,
    payment_type,
    payment_status,
    swap_status,
    failure_reason,
    customer_name,
    plan_type,
    station_name,
    station_city,
    station_state,
    region,
    vehicle_no,
    vehicle_type,
    battery_out_code,
    battery_out_health,
    battery_in_code,
    battery_in_health,
    amount_category,
    swap_month,
    swap_year,
    swap_day_of_week,
    processed_at
FROM {{ ref('int_swaps_enriched') }}

{% if is_incremental() %}
    -- only load rows newer than what already exists in fct_swaps
    WHERE processed_at > (SELECT MAX(processed_at) FROM {{ this }})
{% endif %}