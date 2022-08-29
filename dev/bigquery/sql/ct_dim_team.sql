/*
Create table dim_team
 */
CREATE OR REPLACE TABLE
fantasy_premier_league.dim_team
(
    team_sk STRING NOT NULL,
    team_id STRING NOT NULL,
    team_name STRING,
    team_name_short STRING,
    is_current BOOL,
    start_date DATE,
    end_date DATE
)
OPTIONS(description="Team dimension table")