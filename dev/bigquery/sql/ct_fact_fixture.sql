/*
Create table fact_fixture
 */
CREATE OR REPLACE TABLE
fantasy_premier_league.fact_fixture
(
    fixture_sk STRING NOT NULL,
    fixture_id STRING NOT NULL,
    team_sk_home STRING NOT NULL,
    team_id_home STRING NOT NULL,
    team_sk_away STRING NOT NULL,
    team_id_away STRING NOT NULL,
    team_score_home INTEGER,
    team_score_away INTEGER,
    team_difficulty_home INTEGER,
    team_difficulty_away INTEGER,
    finished BOOLEAN,
    kickoff_time TIMESTAMP,
    source_date DATE NOT NULL
)
OPTIONS(description="Fixture fact table")