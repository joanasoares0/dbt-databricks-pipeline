# Databricks notebook source
# MAGIC %md
# MAGIC # Load raw data
# MAGIC Downloads the job postings dataset from GitHub **straight into a Unity Catalog Volume**
# MAGIC (no local files needed), then creates the raw tables from those files.
# MAGIC
# MAGIC **First time:** import this notebook (Workspace → Import → URL) and click **Run all**.
# MAGIC **After that:** it runs automatically as the first task of the Databricks Job
# MAGIC (`jobs/job_dbt_databricks_pipeline.yml`), straight from this repo.
# MAGIC
# MAGIC Safe to run again: files already in the Volume are skipped, and the raw tables are rebuilt.

# COMMAND ----------

REPO = "lukebarousse/dbt_Analytics_Engineering_Course"
TAG = "dataset-v1"                       # pinned dataset release, so every run gets the same files
VOLUME = "/Volumes/raw/jobs/files"

MONTHS = [
    "2025-07", "2025-08", "2025-09", "2025-10", "2025-11", "2025-12",
    "2026-01", "2026-02", "2026-03", "2026-04", "2026-05", "2026-06",
]
FILES = [f"raw_job_postings_{m}.parquet" for m in MONTHS] + ["raw_job_skills.parquet"]

# COMMAND ----------

# Create where the raw data lives: the raw catalog, a jobs schema and a Volume for the files.
# Only this notebook writes to raw. The dev and prod dbt runs both read from it.
spark.sql("CREATE CATALOG IF NOT EXISTS raw")
spark.sql("CREATE SCHEMA IF NOT EXISTS raw.jobs")
spark.sql("CREATE VOLUME IF NOT EXISTS raw.jobs.files")

# COMMAND ----------

# Download the files from the GitHub release into the Volume (~85 MB in total).
# Files that are already there are skipped.
import urllib.request, os

for name in FILES:
    dest = f"{VOLUME}/{name}"
    if os.path.exists(dest):
        print(f"  already have {name}")
        continue
    print(f"  downloading {name} ...")
    urllib.request.urlretrieve(f"https://github.com/{REPO}/releases/download/{TAG}/{name}", dest)

print("Done.")

# COMMAND ----------

# Create the raw tables from the files, exactly as the scraper delivered them (no cleaning yet)
spark.sql(f"""
    CREATE OR REPLACE TABLE raw.jobs.raw_job_postings AS
    SELECT * FROM read_files('{VOLUME}/raw_job_postings_*.parquet', format => 'parquet')
""")
spark.sql(f"""
    CREATE OR REPLACE TABLE raw.jobs.raw_job_skills AS
    SELECT * FROM read_files('{VOLUME}/raw_job_skills.parquet', format => 'parquet')
""")

# COMMAND ----------

# Quick check: you should see 843,097 postings and 3,304,574 skill rows
display(spark.sql("""
    SELECT 'raw_job_postings' AS table, COUNT(*) AS rows FROM raw.jobs.raw_job_postings
    UNION ALL
    SELECT 'raw_job_skills', COUNT(*) FROM raw.jobs.raw_job_skills
"""))