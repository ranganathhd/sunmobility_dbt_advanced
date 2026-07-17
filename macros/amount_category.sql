-- amount_category.sql
-- categorizes swap amount into High Medium Low
-- reusable across multiple models

{% macro get_amount_category(amount_column) %}
    CASE
        WHEN {{ amount_column }} >= 150 THEN 'High Value'
        WHEN {{ amount_column }} >= 100 THEN 'Medium Value'
        ELSE 'Low Value'
    END
{% endmacro %}