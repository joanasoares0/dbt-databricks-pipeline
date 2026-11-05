{#-
    Feeds the job_postings_snapshot. 
    It is not meant to be queried directly.
    It picks each job's latest row up to a cutoff date (the `as_of` var,
    or today if not set), so you can replay history one day at a time.
    It's ephemeral: dbt inlines it into the snapshot's SQL instead of
    creating a table or view.
-#}

{{ config(materialized='ephemeral') }}

SELECT *
FROM {{ ref('stg_job_postings') }}

-- The cutoff is a whole day: as_of = July 1 includes everything from July 1.
-- (Casting to DATE also drops the +00:00 time zone part of run_started_at.)
WHERE search_date <= CAST('{{ var("as_of", run_started_at) }}' AS DATE)

-- Keep only the most recent scrape of each job before the cutoff.
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY job_id
    ORDER BY searched_at DESC
) = 1