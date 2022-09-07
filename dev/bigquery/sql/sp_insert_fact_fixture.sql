/*
Stored procedure to insert table fact_fixture
*/
CREATE OR REPLACE PROCEDURE `fantasy_premier_league.sp_insert_fact_fixture`(run_date DATE)
BEGIN
-- DELETE EXISTING DATA
DELETE FROM `fantasy_premier_league.fact_fixture` WHERE source_date=run_date;
-- INSERT NEW DATA
INSERT `fantasy_premier_league.fact_fixture`
SELECT
    GENERATE_UUID() as fixture_sk,
    SRCE.fixture_id,
    SRCE.team_sk_home,
    SRCE.team_id_home,
    SRCE.team_sk_away,
    SRCE.team_id_away,
    SRCE.team_score_home,
    SRCE.team_score_away,
    SRCE.team_difficulty_home,
    SRCE.team_difficulty_away,
    SRCE.finished,
    SRCE.kickoff_time,
    SRCE.source_date
FROM (
    SELECT
        MAP_FIXTURE.fixture_id,
        MAP_TEAM_HOME.team_sk as team_sk_home,
        MAP_TEAM_HOME.team_id as team_id_home,
        MAP_TEAM_AWAY.team_sk as team_sk_away,
        MAP_TEAM_AWAY.team_id as team_id_away,
        STAGING.team_h_score as team_score_home,
        STAGING.team_a_score as team_score_away,
        STAGING.team_h_difficulty as team_difficulty_home,
        STAGING.team_a_difficulty as team_difficulty_away,
        STAGING.finished,
        STAGING.kickoff_time,
        STAGING.source_date
    FROM
        `fantasy_premier_league.staging_fantasy_premierleague_api_fixtures` AS STAGING
        INNER JOIN `fantasy_premier_league.metadata_fixture_id_fixtures_code_map` AS MAP_FIXTURE ON STAGING.code = MAP_FIXTURE.fixture_id_source
        AND STAGING.source_date <= MAP_FIXTURE.end_date
        AND STAGING.source_date >= MAP_FIXTURE.start_date
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
        ) AS MAP_TEAM_HOME ON STAGING.team_h = MAP_TEAM_HOME.team_id_source
        AND STAGING.source_date <= MAP_TEAM_HOME.end_date
        AND STAGING.source_date >= MAP_TEAM_HOME.start_date
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
        ) AS MAP_TEAM_AWAY ON STAGING.team_a = MAP_TEAM_AWAY.team_id_source
        AND STAGING.source_date <= MAP_TEAM_AWAY.end_date
        AND STAGING.source_date >= MAP_TEAM_AWAY.start_date
    WHERE STAGING.source_date = run_date
        AND STAGING.finished=TRUE -- insert ONLY when fixture is finished
) AS SRCE
    LEFT JOIN `fantasy_premier_league.fact_fixture` AS TRGT ON SRCE.fixture_id=TRGT.fixture_id
WHERE TRGT.fixture_id IS NULL
;

END