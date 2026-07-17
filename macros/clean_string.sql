-- clean_string.sql
-- reusable macro to clean text columns
-- removes extra spaces and converts to uppercase
-- used in all staging models

{% macro clean_string(column_name) %}
    UPPER(TRIM({{ column_name }}))
{% endmacro %}