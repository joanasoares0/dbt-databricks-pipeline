{#-
    Which companies edit their job postings the most?
    Only the snapshot can answer this: staging has every scrape, but it doesn't
    know whether anything changed between them.

    The trick: if a job has a row where dbt_valid_to IS NOT NULL, an older
    version was replaced, which means the posting was edited at least once.
-#}

SELECT
    company_name,
    COUNT(DISTINCT job_id) AS jobs_changed
FROM {{ ref('job_postings_snapshot') }}
WHERE dbt_valid_to IS NOT NULL
GROUP BY company_name
ORDER BY jobs_changed DESC
LIMIT 10