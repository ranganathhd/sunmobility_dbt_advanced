-- stg_swap_records.sql
-- cleans and standardizes processed swap records
-- reads from processed table — not raw table directly

{{
    config(
        materialized = 'view'
    )
}}

SELECT
    swap_id,
    customer_id,
    UPPER(TRIM(customer_type))   AS customer_type,
    vehicle_id,
    station_id,
    dock_id,
    battery_out,
    battery_in,
    swap_date::DATE              AS swap_date,
    swap_time::TIME              AS swap_time,
    operator_id,
    amount::FLOAT                AS amount,
    UPPER(TRIM(payment_type))    AS payment_type,
    UPPER(TRIM(payment_status))  AS payment_status,
    UPPER(TRIM(swap_status))     AS swap_status,
    failure_reason,
    processed_at::TIMESTAMP      AS processed_at
FROM {{ source('raw', 'swap_records_processed') }}
WHERE swap_id IS NOT NULL