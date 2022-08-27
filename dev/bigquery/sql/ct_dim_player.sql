/*
Create table dim_player
 */
CREATE OR REPLACE TABLE
fantasy_premier_league.dim_player
(
    player_sk STRING NOT NULL,
    player_id STRING NOT NULL,
    player_first_name STRING,
    player_second_name STRING,
    is_current BOOL,
    start_date DATE,
    end_date DATE
)
OPTIONS(description="Player dimension table")