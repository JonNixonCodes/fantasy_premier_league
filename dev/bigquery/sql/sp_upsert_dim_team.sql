/*
Stored procedure to upsert table dim_team
*/
CREATE OR REPLACE PROCEDURE `fantasy_premier_league.sp_upsert_dim_team`(run_date DATE)
BEGIN
-- Merge (insert, update, delete)
MERGE INTO
  `fantasy_premier_league.dim_team` AS T
USING
(
  -- Combined records from source and target tables with merge actions
  SELECT
    coalesce(dim.team_sk,generate_uuid()) as team_sk,
    coalesce(staging.team_id,dim.team_id) as team_id,
    dim.team_name as team_name_current,
    staging.team_name as team_name_new,
    dim.team_name_short as team_name_short_current,
    staging.team_name_short as team_name_short_new,
    CASE
      WHEN dim.team_id IS NULL THEN 'INSERT'
      WHEN staging.team_id IS NULL THEN 'DELETE'
      WHEN staging.row_hash <> dim.row_hash THEN 'UPDATE'
    END
    AS merge_action,
    CASE
      WHEN dim.team_id IS NULL THEN run_date
      ELSE dim.start_date
    END
    AS start_date,
    CASE
      WHEN dim.team_id IS NULL THEN date'9999-12-31'
      ELSE run_date-1
  END
    AS end_date
  FROM
  (
    SELECT SHA256(CONCAT(map.team_id,staging.name,staging.short_name)) as row_hash, map.team_id, staging.name as team_name, staging.short_name as team_name_short
    FROM 
      `fantasy_premier_league.staging_fantasy_premierleague_api_bootstrapstatic_teams` staging
    INNER JOIN
      `fantasy_premier_league.metadata_team_id_teams_code_map` map
    ON
      staging.code=map.team_id_source
    WHERE
      staging.source_date=run_date
      and map.start_date<=run_date
      and map.end_date>=run_date
  ) AS staging
  FULL JOIN 
  (
    SELECT
      SHA256(CONCAT(team_id,team_name,team_name_short)) as row_hash,*
    FROM
      `fantasy_premier_league.dim_team`
    WHERE
      end_date=Date'9999-12-31'
  ) AS dim
  ON
    staging.team_id = dim.team_id
) AS S
ON
  T.team_id = S.team_id
  AND S.merge_action IN ('UPDATE','DELETE')
  -- Update
  WHEN MATCHED AND S.merge_action = 'UPDATE' THEN 
  UPDATE SET end_date = S.end_date, is_current=FALSE
  -- Delete
  WHEN MATCHED AND S.merge_action = 'DELETE' THEN 
  UPDATE SET end_date = S.end_date
  -- Insert
  WHEN NOT MATCHED BY TARGET AND S.merge_action='INSERT' THEN 
  INSERT (team_sk, team_id, team_name, team_name_short, is_current, start_date, end_date) VALUES(S.team_sk, S.team_id, S.team_name_new, S.team_name_short_new, TRUE, S.start_date, S.end_date)
;
END