-- tests/test_swap_amount_positive.sql
-- Business rule: swap amount should never be negative
-- If this query returns rows → test FAILS
-- If no rows returned → test PASSES

SELECT
    swap_id,
    amount
FROM {{ ref('stg_swap_records') }}
WHERE amount < 0
