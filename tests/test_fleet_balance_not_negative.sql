-- tests/test_fleet_balance_not_negative.sql
-- Business rule: fleet customer balance should not go negative
-- Current balance cannot be less than zero

SELECT
    fleet_id,
    company_name,
    current_balance
FROM {{ ref('stg_fleet_customers') }}
WHERE current_balance < 0