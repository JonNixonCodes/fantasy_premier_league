/*
Create table fact_player_fixture
 */
CREATE OR REPLACE TABLE
fantasy_premier_league.fact_player_fixture
(
    player_sk STRING NOT NULL,
    player_id STRING NOT NULL,
    -- fixture_sk STRING NOT NULL,
    fixture_id STRING NOT NULL,
    team_sk STRING NOT NULL,
    team_id STRING NOT NULL,
    team_sk_opponent STRING NOT NULL,
    team_id_opponent STRING NOT NULL,
    round INTEGER,
    was_home BOOLEAN,
    transfers_in INTEGER,
    selected INTEGER,
    value INTEGER,
    ict_index FLOAT64,
    creativity FLOAT64,
    influence FLOAT64,
    bps INTEGER,
    assists INTEGER,
    total_points INTEGER,
    bonus INTEGER,
    saves INTEGER,
    transfers_out INTEGER,
    yellow_cards INTEGER,
    red_cards INTEGER,
    goals_conceded INTEGER,
    transfers_balance INTEGER,
    penalties_missed INTEGER,
    clean_sheets INTEGER,
    goals_scored INTEGER,
    own_goals INTEGER,
    threat FLOAT64,
    minutes INTEGER,
    penalties_saved INTEGER,
    source_date DATE NOT NULL,
)
CLUSTER BY player_sk,team_sk,fixture_id
OPTIONS(description="Player fixture fact table")