{#-
    Which postings changed their salary the most?
    Reads the snapshot, where each version of a job is its own row, so the gap
    between the lowest and highest salary_max is the swing. No LAG needed.
    USD only: otherwise currencies like COP, KRW or INR fill the top 10.

    The top results are mostly typos (e.g. a PMO Analyst going from 60K to
    1,000,000), which makes this a handy data quality check.
-#}

SELECT
    job_title,
    company_name,
    MIN(salary_max) AS lowest_posted,
    MAX(salary_max) AS highest_posted,
    MAX(salary_max) - MIN(salary_max) AS salary_swing
FROM {{ ref('job_postings_snapshot') }}
WHERE salary_currency = 'USD'
GROUP BY job_id, job_title, company_name  -- one row per job; title and company are just for display
ORDER BY salary_swing DESC
LIMIT 10