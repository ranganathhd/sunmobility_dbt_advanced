-- tests/test_swap_date_not_future.sql
-- Business rule: swap date cannot be in the future
-- A swap cannot happen tomorrow or next week

SELECT
    swap_id,
    swap_date
FROM {{ ref('stg_swap_records') }}
WHERE swap_date > CURRENT_DATE