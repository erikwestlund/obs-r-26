INSERT INTO @target_cohort_table (
  cohort_definition_id,
  subject_id,
  cohort_start_date,
  cohort_end_date
)
SELECT
  @target_cohort_id AS cohort_definition_id,
  first_event.person_id AS subject_id,
  first_event.cohort_start_date,
  op.observation_period_end_date AS cohort_end_date
FROM (
  SELECT
    co.person_id,
    MIN(co.condition_start_date) AS cohort_start_date
  FROM @cdm_database_schema.condition_occurrence co
  WHERE co.condition_concept_id = 192671
  GROUP BY co.person_id
) first_event
JOIN @cdm_database_schema.observation_period op
  ON first_event.person_id = op.person_id
  AND first_event.cohort_start_date >= op.observation_period_start_date
  AND first_event.cohort_start_date <= op.observation_period_end_date
WHERE DATEDIFF(day, op.observation_period_start_date, first_event.cohort_start_date) >= 365;
