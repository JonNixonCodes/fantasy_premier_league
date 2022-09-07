/*
 Stored procedure to upsert data from staging to metadata table: metadata_fixture_id_fixtures_id_map
 
 Usage:
 CALL `fantasy_premier_league.sp_upsert_metadata_fixture_id_fixtures_id_map`(DATE '2022-08-21')
 
 Author:
 Jonathan Yu
 */
CREATE
OR REPLACE PROCEDURE `fantasy_premier_league.sp_upsert_metadata_fixture_id_fixtures_id_map`(run_date DATE) 
BEGIN 
MERGE INTO `fantasy_premier_league.metadata_fixture_id_fixtures_id_map` AS T USING (
    -- Combined records from source and target tables with merge actions
    SELECT
        COALESCE(map.fixture_id, staging.fixture_id) AS fixture_id,
        map.fixture_id_source as fixture_id_source_current,
        staging.id as fixture_id_source_new,
        CASE
            WHEN map.fixture_id IS NULL THEN 'INSERT'
            WHEN staging.fixture_id IS NULL THEN 'DELETE'
            WHEN staging.id <> map.fixture_id_source THEN 'UPDATE'
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
                staging.id,
                map.fixture_id
            FROM
                `fantasy_premier_league.staging_fantasy_premierleague_api_fixtures` staging
                INNER JOIN `fantasy_premier_league.metadata_fixture_id_fixtures_code_map` map ON staging.code = map.fixture_id_source
            WHERE
                staging.source_date = run_date
                and map.start_date <= run_date
                and map.end_date >= run_date
        ) AS staging 
        FULL JOIN 
        (
            SELECT
                *
            FROM
                `fantasy_premier_league.metadata_fixture_id_fixtures_id_map`
            WHERE
                end_date = Date '9999-12-31'
        ) AS map ON staging.fixture_id = map.fixture_id
) AS S ON T.fixture_id = S.fixture_id
AND S.merge_action IN ('UPDATE', 'DELETE')
WHEN MATCHED
AND S.merge_action = 'UPDATE' THEN -- Update
UPDATE
SET
    end_date = S.end_date,
    is_current = FALSE
WHEN MATCHED
AND S.merge_action = 'DELETE' THEN -- Delete
UPDATE
SET
    end_date = S.end_date
WHEN NOT MATCHED BY TARGET
AND S.merge_action = 'INSERT' THEN -- Insert
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
        S.fixture_id_source_new,
        TRUE,
        S.start_date,
        S.end_date
    );

END