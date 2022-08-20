/*
Upsert table metadata_player_id_elements_code_map
*/
-- Set which source date to use for upsert (snapshot data)
DECLARE run_date DATE;
SET run_date=(SELECT max(source_date) FROM `fantasy_premier_league.staging_fantasy_premierleague_api_bootstrapstatic_elements`);
-- Merge (insert and delete)
MERGE INTO
  `fantasy_premier_league.metadata_player_id_elements_code_map` AS T
USING
(
  -- Combined records from source and target tables with merge actions
  SELECT
    COALESCE(staging.code,map.player_id_source) AS player_id_source,
    COALESCE(map.player_id,GENERATE_UUID()) AS player_id,
    CASE
      WHEN map.player_id IS NULL THEN 'INSERT'
      WHEN staging.code IS NULL THEN 'DELETE'
  END
    AS merge_action,
    CASE
      WHEN map.player_id IS NULL THEN run_date
    ELSE
    map.start_date
  END
    AS start_date,
    CASE
      WHEN map.player_id IS NULL THEN date'9999-12-31'
    ELSE
    run_date-1
  END
    AS end_date
  FROM
  (
    SELECT
      *
    FROM
      `fantasy_premier_league.staging_fantasy_premierleague_api_bootstrapstatic_elements` 
    WHERE
      source_date=run_date
  ) AS staging
  FULL JOIN 
  (
    SELECT
      *
    FROM
      `fantasy_premier_league.metadata_player_id_elements_code_map`
    WHERE
      end_date=Date'9999-12-31'
  ) AS map
  ON
    staging.code = map.player_id_source
) AS S
ON
  T.player_id = S.player_id
  AND S.merge_action IN ('DELETE')
  -- delete
  WHEN MATCHED AND S.merge_action = 'DELETE' THEN 
  UPDATE SET end_date = S.end_date
  -- insert
  WHEN NOT MATCHED BY TARGET AND S.merge_action='INSERT' THEN 
  INSERT (player_id, player_id_source, is_current, start_date, end_date) VALUES(S.player_id, S.player_id_source, TRUE, S.start_date, S.end_date)
;