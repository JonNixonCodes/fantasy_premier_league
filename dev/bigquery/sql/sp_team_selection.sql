/*
 Stored procedure to refresh ana_team_selection table and view.
 
 Usage:
 CALL `fantasy_premier_league.sp_team_selection`(DATE '2022-08-21')
 
 Author:
 Jonathan Yu
 */
CREATE OR REPLACE PROCEDURE `fantasy_premier_league.sp_team_selection`(run_date DATE) 
BEGIN 


-- Players
CREATE TEMP TABLE 
player
AS
SELECT
    fpd.source_date,
    fpd.player_sk,
    dp.player_first_name,
    dp.player_second_name,
    dt.team_name,
    fpd.position_id,
    fpd.now_cost,
    fpd.selected_by_percent,
  FROM
    `fantasy_premier_league.fact_player_day` fpd,
    `fantasy_premier_league.dim_player` dp,
    `fantasy_premier_league.dim_team` dt
  WHERE
    1=1
    AND fpd.player_sk=dp.player_sk
    AND fpd.team_sk=dt.team_sk
    AND fpd.source_date=run_date
;


-- Goalkeeper temp table
CREATE TEMP TABLE
player_gkp
AS
SELECT 
    player_sk,
    ROW_NUMBER() OVER(ORDER BY selected_by_percent DESC) AS row_nm
  FROM 
    player
  WHERE
    position_id='GKP'
  QUALIFY
    row_nm <= 5;

-- Defender temp table
CREATE TEMP TABLE
player_def
AS
SELECT 
    player_sk,
    ROW_NUMBER() OVER(ORDER BY selected_by_percent DESC) AS row_nm
  FROM 
    player
  WHERE
    position_id='DEF'
  QUALIFY
    row_nm <= 8;

-- Midfielder temp table
CREATE TEMP TABLE
player_mid
AS
SELECT 
    player_sk,
    ROW_NUMBER() OVER(ORDER BY selected_by_percent DESC) AS row_nm
  FROM 
    player
  WHERE
    position_id='MID'
  QUALIFY
    row_nm <= 8;


-- Forward temp table
CREATE TEMP TABLE
player_fwd
AS
SELECT 
    player_sk,
    ROW_NUMBER() OVER(ORDER BY selected_by_percent DESC) AS row_nm
  FROM 
    player
  WHERE
    position_id='FWD'
  QUALIFY
    row_nm <= 5;


-- Team selection combinations
CREATE TEMP TABLE
selection_comb
AS
SELECT
    GENERATE_UUID() AS selection_id,
    gkp1.player_sk AS player1,
    gkp2.player_sk AS player2,
    def1.player_sk AS player3,
    def2.player_sk AS player4,
    def3.player_sk AS player5,
    def4.player_sk AS player6,
    def5.player_sk AS player7,
    mid1.player_sk AS player8,
    mid2.player_sk AS player9,
    mid3.player_sk AS player10,
    mid4.player_sk AS player11,
    mid5.player_sk AS player12,
    fwd1.player_sk AS player13,
    fwd2.player_sk AS player14,
    fwd3.player_sk AS player15,
  FROM
    player_gkp AS gkp1,
    player_gkp AS gkp2,
    player_def AS def1,
    player_def AS def2,
    player_def AS def3,
    player_def AS def4,
    player_def AS def5,
    player_mid AS mid1,
    player_mid AS mid2,
    player_mid AS mid3,
    player_mid AS mid4,
    player_mid AS mid5,
    player_fwd AS fwd1,
    player_fwd AS fwd2,
    player_fwd AS fwd3
  WHERE
    1=1
    AND gkp2.row_nm > gkp1.row_nm
    AND def2.row_nm > def1.row_nm
    AND def3.row_nm > def2.row_nm
    AND def4.row_nm > def3.row_nm
    AND def5.row_nm > def4.row_nm
    AND mid2.row_nm > mid1.row_nm
    AND mid3.row_nm > mid2.row_nm
    AND mid4.row_nm > mid3.row_nm
    AND mid5.row_nm > mid4.row_nm
    AND fwd2.row_nm > fwd1.row_nm
    AND fwd3.row_nm > fwd2.row_nm;

CREATE TEMP TABLE
selection_comb_long
AS
SELECT selection_id,player1 AS player_sk FROM selection_comb
UNION ALL
SELECT selection_id,player2 AS player_sk FROM selection_comb
UNION ALL
SELECT selection_id,player3 AS player_sk FROM selection_comb
UNION ALL
SELECT selection_id,player4 AS player_sk FROM selection_comb
UNION ALL
SELECT selection_id,player5 AS player_sk FROM selection_comb
UNION ALL
SELECT selection_id,player6 AS player_sk FROM selection_comb
UNION ALL
SELECT selection_id,player7 AS player_sk FROM selection_comb
UNION ALL
SELECT selection_id,player8 AS player_sk FROM selection_comb
UNION ALL
SELECT selection_id,player9 AS player_sk FROM selection_comb
UNION ALL
SELECT selection_id,player10 AS player_sk FROM selection_comb
UNION ALL
SELECT selection_id,player11 AS player_sk FROM selection_comb
UNION ALL
SELECT selection_id,player12 AS player_sk FROM selection_comb
UNION ALL
SELECT selection_id,player13 AS player_sk FROM selection_comb
UNION ALL
SELECT selection_id,player14 AS player_sk FROM selection_comb
UNION ALL
SELECT selection_id,player15 AS player_sk FROM selection_comb;


-- selection metrics
CREATE TEMP TABLE
selection
AS
SELECT
    s.selection_id,
    p.*
  FROM
    selection_comb_long s,
    player p
  WHERE
    s.player_sk=p.player_sk;


-- selection cost
CREATE TEMP TABLE
selection_cost
AS
SELECT
    selection_id,
    SUM(now_cost) AS selection_cost
  FROM
    selection
  GROUP BY
    1;


-- selection score
CREATE TEMP TABLE
selection_score
AS
SELECT
    selection_id,
    SUM(selected_by_percent) AS selection_score
  FROM
    selection
  GROUP BY
    1;


-- selection team condition
CREATE TEMP TABLE
selection_max_team_players
AS
WITH team_players AS (
  SELECT
      selection_id,
      team_name,
      COUNT(*) AS team_players
    FROM
      selection
    GROUP BY
      1,2
)
SELECT
    selection_id,
    MAX(team_players.team_players) AS selection_max_team_players
  FROM
    team_players
  GROUP BY
    1
;


-- final table
CREATE OR REPLACE TABLE
`sandbox-egl1hjn.fantasy_premier_league.ana_team_selection`
AS
SELECT
    s.*,
    selection_cost,
    selection_score,
    selection_max_team_players,
    DENSE_RANK() OVER(ORDER BY selection_score DESC, selection_cost ASC, s.selection_id) AS selection_rank
  FROM
    selection s,
    selection_cost sc,
    selection_score ss,
    selection_max_team_players smtp
  WHERE
    1=1
    AND s.selection_id=sc.selection_id
    AND s.selection_id=ss.selection_id
    AND s.selection_id=smtp.selection_id;


-- final view
CREATE OR REPLACE VIEW
`sandbox-egl1hjn.fantasy_premier_league.ana_team_selection_vw`
AS
SELECT
    *
  FROM
    `sandbox-egl1hjn.fantasy_premier_league.ana_team_selection`
  WHERE
    1=1
    AND selection_cost <= 1000
    AND selection_max_team_players <= 3
  ORDER BY
    selection_rank ASC,
    CASE WHEN position_id='GKP' THEN 0 WHEN position_id='DEF' THEN 1 WHEN position_id='MID' THEN 2 WHEN position_id='FWD' THEN 3 ELSE 4 END ASC,
    now_cost DESC,
    player_second_name ASC;


END