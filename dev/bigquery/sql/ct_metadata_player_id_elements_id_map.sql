/*
Create table metadata_player_id_elements_id_map
 */
CREATE OR REPLACE TABLE
fantasy_premier_league.metadata_player_id_elements_id_map
(
  player_id STRING NOT NULL,
  player_id_source INT NOT NULL,
  is_current BOOL NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL
)
OPTIONS(description="Mapping table between `player_id` and `id` from staging_fantasy_premierleague_api_bootstrapstatic_elements")