-- alert_severity_flag.sql
-- returns True if alert is critical or high severity
-- reusable across station and battery alert models

{% macro is_high_priority_alert(severity_column) %}
    CASE
        WHEN {{ severity_column }} IN ('CRITICAL', 'HIGH') THEN TRUE
        ELSE FALSE
    END
{% endmacro %}