/*
Stored procedure to insert table fact_player_fixture
*/
CREATE OR REPLACE PROCEDURE `fantasy_premier_league.sp_insert_fact_player_fixture`(run_date DATE)
BEGIN
-- DELETE EXISTING DATA
-- DELETE FROM `fantasy_premier_league.fact_player_fixture` WHERE source_date=run_date;
TRUNCATE TABLE `fantasy_premier_league.fact_player_fixture`;
-- INSERT NEW DATA
INSERT `fantasy_premier_league.fact_player_fixture`
SELECT
    SRCE.player_sk,
    SRCE.player_id,
    -- SRCE.fixture_sk,
    SRCE.fixture_id,
    SRCE.team_sk,
    SRCE.team_id,
    SRCE.team_sk_opponent,
    SRCE.team_id_opponent,
    SRCE.round,
    SRCE.was_home,
    SRCE.transfers_in,
    SRCE.selected,
    SRCE.value,
    SRCE.ict_index,
    SRCE.creativity,
    SRCE.influence,
    SRCE.bps,
    SRCE.assists,
    SRCE.total_points,
    SRCE.bonus,
    SRCE.saves,
    SRCE.transfers_out,
    SRCE.yellow_cards,
    SRCE.red_cards,
    SRCE.goals_conceded,
    SRCE.transfers_balance,
    SRCE.penalties_missed,
    SRCE.clean_sheets,
    SRCE.goals_scored,
    SRCE.own_goals,
    SRCE.threat,
    SRCE.minutes,
    SRCE.penalties_saved,
    SRCE.source_date
FROM (
    SELECT
        MAP_PLAYER.player_sk,MAP_PLAYER.player_id,
        -- MAP_FIXTURE.fixture_sk,
        MAP_FIXTURE.fixture_id,
        MAP_TEAM.team_sk,MAP_TEAM.team_id,
        MAP_TEAM_OPPONENT.team_sk as team_sk_opponent,MAP_TEAM_OPPONENT.team_id as team_id_opponent,
        STAGING.*
    FROM
        `fantasy_premier_league.staging_fantasy_premierleague_api_elementsummary_history` AS STAGING
        INNER JOIN (
            SELECT
                MAP.player_id_source,
                DIM.player_sk,
                DIM.player_id,
                DIM.start_date,
                DIM.end_date,
                DIM.is_current
            FROM
                `fantasy_premier_league.metadata_player_id_elements_id_map` AS MAP
                INNER JOIN `fantasy_premier_league.dim_player` AS DIM ON MAP.player_id = DIM.player_id
        ) AS MAP_PLAYER ON STAGING.element_id = MAP_PLAYER.player_id_source
        AND STAGING.source_date <= MAP_PLAYER.end_date
        AND STAGING.source_date >= MAP_PLAYER.start_date
        INNER JOIN `fantasy_premier_league.metadata_fixture_id_fixtures_id_map` AS MAP_FIXTURE ON STAGING.fixture = MAP_FIXTURE.fixture_id_source
        AND STAGING.source_date <= MAP_FIXTURE.end_date
        AND STAGING.source_date >= MAP_FIXTURE.start_date
        INNER JOIN (
            SELECT
                ELEM.id,DIM_TEAM.team_sk,DIM_TEAM.team_id,
                -- MAP_TEAM.start_date,
                -- MAP_TEAM.end_date,
                -- MAP_TEAM.is_current,
                -- DIM_TEAM.start_date,
                -- DIM_TEAM.end_date,
                -- DIM_TEAM.is_current
            FROM
                `fantasy_premier_league.staging_fantasy_premierleague_api_bootstrapstatic_elements` AS ELEM
                INNER JOIN `fantasy_premier_league.metadata_team_id_teams_id_map` AS MAP_TEAM ON ELEM.team=MAP_TEAM.team_id_source
                INNER JOIN `fantasy_premier_league.dim_team` AS DIM_TEAM ON MAP_TEAM.team_id = DIM_TEAM.team_id
            WHERE ELEM.source_date=run_date
                AND ELEM.source_date<=MAP_TEAM.end_date
                AND ELEM.source_date>=MAP_TEAM.start_date
                AND ELEM.source_date<=DIM_TEAM.end_date
                AND ELEM.source_date>=DIM_TEAM.start_date
        ) AS MAP_TEAM ON STAGING.element_id = MAP_TEAM.id
        INNER JOIN (
            SELECT
                MAP.team_id_source,
                DIM.team_sk,
                DIM.team_id,
                DIM.start_date,
                DIM.end_date,
                DIM.is_current
            FROM
                `fantasy_premier_league.metadata_team_id_teams_id_map` AS MAP
                INNER JOIN `fantasy_premier_league.dim_team` AS DIM ON MAP.team_id = DIM.team_id
        ) AS MAP_TEAM_OPPONENT ON STAGING.opponent_team = MAP_TEAM_OPPONENT.team_id_source
        AND STAGING.source_date <= MAP_TEAM_OPPONENT.end_date
        AND STAGING.source_date >= MAP_TEAM_OPPONENT.start_date
    WHERE STAGING.source_date = run_date
) AS SRCE
    LEFT JOIN `fantasy_premier_league.fact_player_fixture` AS TRGT 
        ON SRCE.fixture_id=TRGT.fixture_id
        AND SRCE.player_id=TRGT.player_id
WHERE TRGT.fixture_id IS NULL
AND TRGT.player_id IS NULL
;

END