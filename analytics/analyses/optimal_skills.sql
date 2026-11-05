{#-
    Which skills are both in high demand AND well paid?
    Only skills in at least 100 postings are ranked, so a skill that appears in
    one high-paying posting doesn't end up at the top.

    Demand counts every job. 
    The salary average only uses jobs that list a
    yearly USD salary (AVG skips NULLs on its own).
-#}

WITH bridge AS (
    SELECT DISTINCT job_id, skill_id FROM {{ ref('bridge_job_skills') }}
),

job_postings AS (
    -- Only yearly USD salaries are compared; other salaries become NULL.
    -- We use CASE instead of WHERE so every job still counts toward demand.
    SELECT
        job_id,
        CASE
            WHEN salary_currency = 'USD' AND salary_period = 'year'
            THEN salary_avg
        END AS salary_year_usd
    FROM {{ ref('fct_job_postings') }}
),

skills AS (
    SELECT * FROM {{ ref('dim_skill') }}
)

SELECT
    skills.display_name,
    skills.category,
    COUNT(DISTINCT bridge.job_id) AS demand_count,
    ROUND(demand_count / (SELECT COUNT(DISTINCT job_id) FROM job_postings) * 100, 1) AS demand_pct,
    ROUND(AVG(job_postings.salary_year_usd), 0) AS avg_salary_year
FROM bridge
INNER JOIN job_postings USING (job_id)
INNER JOIN skills USING (skill_id)
GROUP BY skills.display_name, skills.category
HAVING COUNT(DISTINCT bridge.job_id) >= 100
   AND AVG(job_postings.salary_year_usd) IS NOT NULL
ORDER BY avg_salary_year DESC, demand_count DESC