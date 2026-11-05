WITH skill_categories AS (
    SELECT * FROM {{ ref('skill_categories') }}
),

observations AS (
    SELECT * FROM {{ ref('int_skill_observations') }}
)

-- One row per skill. The counting already happened in int_skill_observations;
-- this model just adds names and categories from the skill_categories seed.
SELECT
    skill_id,
    display_name,
    category,
    subcategory,
    COALESCE(postings_with_skill, 0) AS postings_with_skill
FROM skill_categories
LEFT JOIN observations USING (skill_id)