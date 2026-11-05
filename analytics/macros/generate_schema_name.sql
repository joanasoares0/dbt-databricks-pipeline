{#-
    Use custom schema names exactly as written.

    By default, dbt adds the target schema in front of any custom schema,
    so a model configured with schema='staging' ends up in "default_staging".
    This override keeps dbt's built-in logic with one small change: when a
    model sets a custom schema, we use that name as-is (e.g. "staging").

    Notes:
      - The macro must be named generate_schema_name so dbt picks it up on
        every run. A copy named default__generate_schema_name may seem to work
        with `dbt show` but gets ignored during a real `dbt build`.
      - Dev and prod are kept apart by catalog, not by schema prefix:
        dev uses the catalog from the profile, and prod's catalog is set by
        the scheduled job. 
        Raw data lives in its own shared catalog.
-#}

{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}

        {{ default_schema }}

    {%- else -%}

        {{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}