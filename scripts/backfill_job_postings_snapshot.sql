-- Backfill: rebuild a year of snapshot history in one query.
-- It gives the same result as running `dbt snapshot` once a day for a year.
-- It rebuilds dev.snapshots.job_postings_snapshot (one version per job per
-- day) from all scrapes in staging. After that, `dbt snapshot` carries on
-- as if it had been running all along.
--
-- How to use: paste into the Databricks SQL editor and run it once.
-- Warning: CREATE OR REPLACE overwrites the existing snapshot table.

CREATE OR REPLACE TABLE dev.snapshots.job_postings_snapshot AS
WITH deduped AS (
    -- keep the latest scrape of each job per day (same rule as stg_job_postings_current)
    SELECT *
    FROM dev.staging.stg_job_postings
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY job_id, search_date
        ORDER BY searched_at DESC
    ) = 1
),

sigged AS (
    -- build a fingerprint (hash) of the 13 columns the snapshot tracks
    -- (NULLs become '~' so they still count in the hash)
    SELECT *,
        MD5(CONCAT_WS('||',
            COALESCE(job_title, '~'), COALESCE(company_name, '~'),
            COALESCE(job_location, '~'), COALESCE(job_schedule_type, '~'),
            COALESCE(CAST(job_work_from_home AS STRING), '~'),
            COALESCE(CAST(salary_min AS STRING), '~'),
            COALESCE(CAST(salary_max AS STRING), '~'),
            COALESCE(salary_period, '~'), COALESCE(salary_currency, '~'),
            COALESCE(CAST(has_health_insurance AS STRING), '~'),
            COALESCE(CAST(has_dental_insurance AS STRING), '~'),
            COALESCE(CAST(has_paid_time_off AS STRING), '~'),
            COALESCE(CAST(has_no_degree_mentioned AS STRING), '~')
        )) AS _sig
    FROM deduped
),

versions AS (
    -- keep a row only when something changed since the job's previous scrape
    SELECT *
    FROM (
        SELECT *,
            LAG(_sig) OVER (PARTITION BY job_id ORDER BY searched_at) AS _prev_sig
        FROM sigged
    )
    WHERE _prev_sig IS NULL OR _sig != _prev_sig
)

SELECT
    * EXCEPT (_sig, _prev_sig),
    MD5(CONCAT(job_id, '|', CAST(searched_at AS STRING))) AS dbt_scd_id,
    searched_at AS dbt_updated_at,
    searched_at AS dbt_valid_from,
    LEAD(searched_at) OVER (PARTITION BY job_id ORDER BY searched_at) AS dbt_valid_to
FROM versions