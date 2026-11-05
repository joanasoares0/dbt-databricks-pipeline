WITH job_postings AS (
    SELECT * FROM {{ ref('fct_job_postings') }}
)

SELECT
    company_name,
    COUNT(*) AS total_job_postings,

    -- Average only yearly USD salaries, so we never mix currencies or periods.
    -- We use CASE inside AVG instead of a WHERE filter, because a WHERE would
    -- also remove those postings.
    AVG(CASE
        WHEN salary_currency = 'USD' AND salary_period = 'year'
        THEN salary_avg
    END) AS avg_salary_year

FROM job_postings

-- company_name is the key of this table (one row per company), so it can't be NULL
WHERE 1=1
AND company_name IS NOT NULL

GROUP BY company_name