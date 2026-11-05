{#-
    Which skills appear in the most job postings?
    Joins fct_job_postings, bridge_job_skills and dim_skill.

    This is an analysis, not a model: dbt compiles it but never creates a table.
    
    It covers all roles by default. To look at one role:
      dbt compile --select in_demand_skills --vars 'job_title: Data Analyst'
    Then open target/compiled/analytics/analyses/in_demand_skills.sql
    (compile writes the SQL to that file, it doesn't print it).
-#}

WITH job_postings AS (

    SELECT job_id
    FROM {{ ref('fct_job_postings') }}
    
    {% if var('job_title', none) %}
    WHERE search_term = '{{ var("job_title") }}'
    {% endif %}

),

bridge AS (
    SELECT * FROM {{ ref('bridge_job_skills') }}
),

skills AS (
    SELECT * FROM {{ ref('dim_skill') }}
)

SELECT
    display_name,
    category,
    COUNT(DISTINCT job_id) AS demand_count,
    ROUND(demand_count / (SELECT COUNT(DISTINCT job_id) FROM job_postings) * 100, 1) AS demand_pct
FROM bridge
INNER JOIN skills USING (skill_id)
INNER JOIN job_postings USING (job_id)
GROUP BY skill_id, skills.display_name, skills.category
ORDER BY demand_count DESC