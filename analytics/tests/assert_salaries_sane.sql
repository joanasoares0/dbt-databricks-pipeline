{#-
    Sanity check: flags yearly USD salaries of $1,000,000 or more.

    Why only USD? In currencies like ₹, ZAR or PKR, seven-figure yearly salaries
    are normal. 
    Checking every currency flagged 7,232 rows, mostly false alarms
    (4,248 in ₹ alone). 
    In USD it flags just 27 rows, all ranges ending in "1M",
    which look like typos rather than real salaries.

    Example: Kobie Marketing's Decision Sciences Analyst showed 800K–1M in one
    scrape, but 90K–125K in the other four. The employer fixed it within days.

    Why staging and not fct_job_postings? fct keeps only the latest scrape of
    each job, so corrected typos like this one would be hidden there.

    Set to warn, not error: these are known quirks in the source data,
    not a bug in the pipeline.
-#}

{{ config(severity = 'warn') }}

SELECT
    job_id,
    company_name,
    job_title,
    salary_min,
    salary_max,
    salary_period,
    salary_currency,
    searched_at
FROM {{ ref('stg_job_postings') }}
WHERE 1=1
    AND salary_period = 'year'
    AND salary_currency = 'USD'
    AND COALESCE(salary_max, salary_min) >= 1000000