{#-
    Turn salary text into a number.

    Pass 'min' for the lower bound or 'max' for the upper bound, e.g.
    '$100K–$186K a year' gives 100000 for min and 186000 for max.
    The query calling this macro must have the raw job_salary column available.

    What it handles:
      - ranges split by an en dash ('100K–186K a year')
      - single values (used for both min and max)
      - K and M suffixes, thousands commas and decimals
      - currency symbols are skipped here (salary_currency handles those)
-#}
{% macro parse_salary(part) -%}

    {%- if part == 'min' -%}
        {%- set segment = "split(job_salary, '–')[0]" -%}

    {%- else -%}
        {%- set segment = "element_at(split(job_salary, '–'), -1)" -%}

    {%- endif -%}

    TRY_CAST(REPLACE(REGEXP_EXTRACT({{ segment }}, '([0-9][0-9,.]*)', 1), ',', '') AS DECIMAL(15, 2))
        * CASE UPPER(REGEXP_EXTRACT({{ segment }}, '[0-9][0-9,.]*([KkMm])', 1))
            WHEN 'K' THEN 1000
            WHEN 'M' THEN 1000000
            ELSE 1
          END
          
{%- endmacro %}