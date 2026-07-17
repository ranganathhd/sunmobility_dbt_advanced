-- rupees_conversion.sql
-- converts paise to rupees
-- useful when source system stores amounts in paise

{% macro paise_to_rupees(column_name) %}
    ROUND({{ column_name }} / 100, 2)
{% endmacro %}