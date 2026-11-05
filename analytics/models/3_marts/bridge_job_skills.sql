WITH job_skills AS (
    SELECT * FROM {{ ref('stg_job_skills') }}
),

job_postings AS (
    SELECT * FROM {{ ref('fct_job_postings') }}
)

-- The INNER JOIN keeps only skills for jobs that exist in fct_job_postings.
-- Today it doesn't drop any rows, but it guarantees every job_id here
-- matches a job in fct, even if the data changes later.
SELECT
    job_id,
    skill_id,
    skill_keyword
FROM job_skills
INNER JOIN job_postings USING (job_id)