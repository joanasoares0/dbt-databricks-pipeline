{#-
    One row per job and skill keyword. The same skill_id can appear twice on a
    job when the posting names it two ways (e.g. 'spark' and 'pyspark').
-#}

WITH source AS (
    SELECT *
    FROM {{ source('jobs', 'raw_job_skills') }}
),

cleaned AS (
    SELECT
        job_id,
        skill_id,
        TRIM(skill_keyword) AS skill_keyword  -- remove extra spaces (same as company_name in stg_job_postings)
    FROM source
)

SELECT * FROM cleaned