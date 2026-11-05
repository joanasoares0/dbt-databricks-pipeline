{#-
    Turn a label into a column-friendly name:
    lowercase, with spaces replaced by underscores ('Paid time off' -> paid_time_off).
-#}
{% macro slugify(text) -%}

    {{ text | lower | replace(' ', '_') }}
    
{%- endmacro %}