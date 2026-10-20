-- Macros = Named Jinja Functions
{% macro pct_change(column, partition_by, order_by) %}
    ({{ column }} / nullif(lag({{ column }}) over (partition by {{ partition_by }} order by {{ order_by }}), 0) - 1)
{% endmacro %}