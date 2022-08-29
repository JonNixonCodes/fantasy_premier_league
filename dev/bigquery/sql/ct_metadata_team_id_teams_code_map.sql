/*
Create table metadata_team_id_teams_code_map
 */
CREATE OR REPLACE TABLE
fantasy_premier_league.metadata_team_id_teams_code_map
(
  team_id STRING NOT NULL,
  team_id_source INT NOT NULL,
  is_current BOOL NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL
)
OPTIONS(description="Mapping table between `team_id` and `code` from staging_fantasy_premierleague_api_bootstrapstatic_teams")