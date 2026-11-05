{#-
    Which skills pay the most? 
    Average yearly salary per skill.

    To compare like with like, only yearly USD salaries are used
    (filtered on salary_currency and salary_period).
-#}

WITH bridge AS (
    SELECT DISTINCT job_id, skill_id FROM {{ ref('bridge_job_skills') }}
),

job_postings AS (
    SELECT job_id, salary_avg
    FROM {{ ref('fct_job_postings') }}
    WHERE salary_currency = 'USD'
      AND salary_period = 'year'
      AND salary_avg IS NOT NULL
),

skills AS (
    SELECT * FROM {{ ref('dim_skill') }}
)

SELECT
    skills.skill_id,
    skills.display_name,
    skills.category,
    ROUND(AVG(job_postings.salary_avg), 0) AS avg_salary_year,
    COUNT(*) AS salaried_postings
FROM bridge
INNER JOIN job_postings USING (job_id)
INNER JOIN skills USING (skill_id)
GROUP BY skills.skill_id, skills.display_name, skills.category
ORDER BY avg_salary_year DESC