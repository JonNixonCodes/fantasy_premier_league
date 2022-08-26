/*
Stored procedure to upsert table DimPlayer
*/
CREATE OR REPLACE PROCEDURE `fantasy_premier_league.sp_upsert_dimplayer`(run_date DATE)
BEGIN
-- Merge (insert, update, delete)
MERGE INTO
  `fantasy_premier_league.DimPlayer` AS T
USING
(
  -- Combined records from source and target tables with merge actions
  SELECT
    coalesce(dim.player_sk,generate_uuid()) as player_sk,
    coalesce(staging.player_id,dim.player_id) as player_id,
    dim.player_first_name as player_first_name_current,
    staging.first_name as player_first_name_new,
    dim.player_second_name as player_second_name_current,
    staging.second_name as player_second_name_new,
    CASE
      WHEN dim.player_id IS NULL THEN 'INSERT'
      WHEN staging.player_id IS NULL THEN 'DELETE'
      WHEN staging.row_hash <> dim.row_hash THEN 'UPDATE'
    END
    AS merge_action,
    CASE
      WHEN dim.player_id IS NULL THEN run_date
      ELSE dim.start_date
    END
    AS start_date,
    CASE
      WHEN dim.player_id IS NULL THEN date'9999-12-31'
      ELSE run_date-1
  END
    AS end_date
  FROM
  (
    SELECT SHA256(CONCAT(map.player_id,staging.first_name,staging.second_name)) as row_hash, map.player_id, staging.first_name, staging.second_name
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
      SHA256(CONCAT(player_id,player_first_name,player_second_name)) as row_hash,*
    FROM
      `fantasy_premier_league.DimPlayer`
    WHERE
      end_date=Date'9999-12-31'
  ) AS dim
  ON
    staging.player_id = dim.player_id
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
  INSERT (player_sk, player_id, player_first_name, player_second_name, is_current, start_date, end_date) VALUES(S.player_sk, S.player_id, S.player_first_name_new, S.player_second_name_new, TRUE, S.start_date, S.end_date)
;
END