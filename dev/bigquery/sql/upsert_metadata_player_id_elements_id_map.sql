/*
Stored procedure to upsert data from staging to metadata table: metadata_player_id_elements_id_map

Usage:
CALL `fantasy_premier_league.sp_upsert_metadata_player_id_elements_id_map`(DATE '2022-08-21')

Author:
Jonathan Yu
*/
CREATE OR REPLACE PROCEDURE `fantasy_premier_league.sp_upsert_metadata_player_id_elements_id_map`(run_date DATE)
BEGIN
MERGE INTO
  `fantasy_premier_league.metadata_player_id_elements_id_map` AS T
USING
(
  -- Combined records from source and target tables with merge actions
  SELECT
    COALESCE(map.player_id,staging.player_id) AS player_id,
    map.player_id_source as player_id_source_current,
    staging.id as player_id_source_new,
    CASE
      WHEN map.player_id IS NULL THEN 'INSERT'
      WHEN staging.player_id IS NULL THEN 'DELETE'
      WHEN staging.id <> map.player_id_source THEN 'UPDATE'
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
    SELECT staging.id,map.player_id
    FROM 
      `fantasy_premier_league.staging_fantasy_premierleague_api_bootstrapstatic_elements` staging
    INNER JOIN
      `fantasy_premier_league.metadata_player_id_elements_code_map` map
    ON
      staging.code=map.player_id_source
    WHERE
      staging.source_date=run_date
      and map.start_date<=run_date
      and map.end_date>=run_date
  ) AS staging
  FULL JOIN 
  (
    SELECT
      *
    FROM
      `fantasy_premier_league.metadata_player_id_elements_id_map`
    WHERE
      end_date=Date'9999-12-31'
  ) AS map
  ON
    staging.player_id = map.player_id
) AS S
ON
  T.player_id = S.player_id
  AND S.merge_action IN ('UPDATE','DELETE')
  -- Update
  WHEN MATCHED AND S.merge_action = 'UPDATE' THEN 
  UPDATE SET end_date = S.end_date, is_current=FALSE
  -- Delete
  WHEN MATCHED AND S.merge_action = 'DELETE' THEN 
  UPDATE SET end_date = S.end_date
  -- Insert
  WHEN NOT MATCHED BY TARGET AND S.merge_action='INSERT' THEN 
  INSERT (player_id, player_id_source, is_current, start_date, end_date) VALUES(S.player_id, S.player_id_source_new, TRUE, S.start_date, S.end_date)
;
END