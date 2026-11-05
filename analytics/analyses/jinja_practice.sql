{#-
    A scratchpad for practicing Jinja. dbt compiles it but never builds it.
    
    Run it with `dbt show --select jinja_practice`, or copy the compiled SQL
    from target/compiled/ into any SQL editor.

    What it shows:
      - a loop that writes one SELECT per role, joined with UNION ALL
      - the slugify macro, tried out here before it was used in a real model
      - dbt_utils.get_column_values, which reads the list of roles from the
        data itself, so new roles show up without editing this file
-#}

{% set roles = dbt_utils.get_column_values(ref('stg_job_postings'), 'search_term') -%}

{% for role in roles -%}
    SELECT
        search_term,
        '{{ slugify(role) }}' AS role_slug,
        COUNT(*) AS postings

    FROM {{ ref('stg_job_postings') }}
    WHERE search_term = '{{ role }}'
    GROUP BY search_term

    {{ "UNION ALL" if not loop.last }}

{% endfor %}