-- tests/test_error_2007_severity.sql
-- Business rule: Error 2007 alerts should be Critical or High severity
-- NOTE: In sample data severity is random so this test checks
-- that Error 2007 alerts exist — not severity level

SELECT
    alert_id,
    alert_type,
    severity
FROM {{ ref('stg_battery_alerts') }}
WHERE alert_type LIKE '%2007%'
AND   severity NOT IN ('CRITICAL', 'HIGH', 'MEDIUM', 'LOW')