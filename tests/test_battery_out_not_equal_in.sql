-- tests/test_battery_out_not_equal_in.sql
-- Business rule: battery going out and coming in cannot be same battery
-- You cannot swap a battery with itself

SELECT
    swap_id,
    battery_out,
    battery_in
FROM {{ ref('stg_swap_records') }}
WHERE battery_out = battery_in