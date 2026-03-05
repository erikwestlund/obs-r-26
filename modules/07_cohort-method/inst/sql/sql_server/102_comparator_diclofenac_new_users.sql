INSERT INTO @target_cohort_table (
  cohort_definition_id,
  subject_id,
  cohort_start_date,
  cohort_end_date
)
SELECT
  @target_cohort_id AS cohort_definition_id,
  first_exposure.person_id AS subject_id,
  first_exposure.cohort_start_date,
  op.observation_period_end_date AS cohort_end_date
FROM (
  SELECT
    de.person_id,
    MIN(de.drug_exposure_start_date) AS cohort_start_date
  FROM @cdm_database_schema.drug_exposure de
  JOIN @cdm_database_schema.concept_ancestor ca
    ON de.drug_concept_id = ca.descendant_concept_id
  WHERE ca.ancestor_concept_id = 1124300
  GROUP BY de.person_id
) first_exposure
JOIN @cdm_database_schema.observation_period op
  ON first_exposure.person_id = op.person_id
  AND first_exposure.cohort_start_date >= op.observation_period_start_date
  AND first_exposure.cohort_start_date <= op.observation_period_end_date
WHERE DATEDIFF(day, op.observation_period_start_date, first_exposure.cohort_start_date) >= 365;
