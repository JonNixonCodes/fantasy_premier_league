/*
Create table metadata_position_element_type_map
 */
CREATE OR REPLACE TABLE
`fantasy_premier_league.metadata_position_id_element_type_map`
(
  position_id STRING NOT NULL,
  position_id_source INT NOT NULL,
  is_current BOOL NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL
)
OPTIONS(description="Mapping table between `position` and `element_type` from staging_fantasy_premierleague_api_bootstrapstatic_elements")
;
INSERT INTO `fantasy_premier_league.metadata_position_id_element_type_map` (position_id, position_id_source, is_current, start_date, end_date)
VALUES
  ('GKP',1,TRUE,DATE '2022-08-05',DATE '9999-12-31'),
  ('DEF',2,TRUE,DATE '2022-08-05',DATE '9999-12-31'),
  ('MID',3,TRUE,DATE '2022-08-05',DATE '9999-12-31'),
  ('FWD',4,TRUE,DATE '2022-08-05',DATE '9999-12-31')