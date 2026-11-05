{#-
    Counts how many job postings mention each skill.
    Turns 3,304,574 (job, skill keyword) rows into one row per skill.
-#}

WITH job_skills AS (
    SELECT * FROM {{ ref('stg_job_skills') }}
)

SELECT
    skill_id,
    COUNT(DISTINCT job_id) AS postings_with_skill
FROM job_skills
GROUP BY skill_id