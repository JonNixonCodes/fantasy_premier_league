/*
 Stored procedure to upsert data from staging to metadata table: metadata_fixture_id_fixtures_code_map
 
 Usage:
 CALL `fantasy_premier_league.sp_upsert_metadata_fixture_id_fixtures_code_map`(DATE '2022-08-21')
 
 Author:
 Jonathan Yu
 */
CREATE
OR REPLACE PROCEDURE `fantasy_premier_league.sp_upsert_metadata_fixture_id_fixtures_code_map`(run_date DATE) 
BEGIN 
MERGE INTO `fantasy_premier_league.metadata_fixture_id_fixtures_code_map` AS T 
USING(
    -- Combined records from source and target tables with merge actions
    SELECT
        COALESCE(staging.code, map.fixture_id_source) AS fixture_id_source,
        COALESCE(map.fixture_id, GENERATE_UUID()) AS fixture_id,
        CASE
            WHEN map.fixture_id IS NULL THEN 'INSERT'
            WHEN staging.code IS NULL THEN 'DELETE'
        END AS merge_action,
        CASE
            WHEN map.fixture_id IS NULL THEN run_date
            ELSE map.start_date
        END AS start_date,
        CASE
            WHEN map.fixture_id IS NULL THEN date '9999-12-31'
            ELSE run_date -1
        END AS end_date
    FROM
        (
            SELECT
                *
            FROM
                `fantasy_premier_league.staging_fantasy_premierleague_api_fixtures`
            WHERE
                source_date = run_date
        ) AS staging
        FULL JOIN (
            SELECT
                *
            FROM
                `fantasy_premier_league.metadata_fixture_id_fixtures_code_map`
            WHERE
                end_date = Date '9999-12-31'
        ) AS map ON staging.code = map.fixture_id_source
) AS S ON T.fixture_id = S.fixture_id
AND S.merge_action IN ('DELETE') -- delete
WHEN MATCHED
AND S.merge_action = 'DELETE' THEN
UPDATE
SET
    end_date = S.end_date -- insert
WHEN NOT MATCHED BY TARGET
AND S.merge_action = 'INSERT' THEN
INSERT
    (
        fixture_id,
        fixture_id_source,
        is_current,
        start_date,
        end_date
    )
VALUES
    (
        S.fixture_id,
        S.fixture_id_source,
        TRUE,
        S.start_date,
        S.end_date
    );

END