/*
Create table metadata_fixture_id_fixtures_code_map
 */
CREATE OR REPLACE TABLE
fantasy_premier_league.metadata_fixture_id_fixtures_code_map
(
  fixture_id STRING NOT NULL,
  fixture_id_source INT NOT NULL,
  is_current BOOL NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL
)
OPTIONS(description="Mapping table between `fixture_id` and `code` from staging_fantasy_premierleague_api_fixtures")