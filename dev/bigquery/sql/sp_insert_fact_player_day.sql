/*
Stored procedure to insert table fact_player_day
*/
CREATE OR REPLACE PROCEDURE `fantasy_premier_league.sp_insert_fact_player_day`(run_date DATE)
BEGIN
-- DELETE EXISTING DATA
DELETE FROM `fantasy_premier_league.fact_player_day` WHERE source_date=run_date
;
-- INSERT NEW DATA
INSERT `fantasy_premier_league.fact_player_day`
SELECT
  MAP_PLAYER.player_sk,
  MAP_PLAYER.player_id,
  MAP_TEAM.team_sk,
  MAP_TEAM.team_id,
  MAP_POSITION.position_id,
  STAGING.ict_index_rank,
  STAGING.threat_rank,
  STAGING.influence_rank_type,
  STAGING.ict_index_rank_type,
  STAGING.threat,
  STAGING.bps,
  STAGING.cost_change_event_fall,
  STAGING.penalties_saved,
  STAGING.status,
  STAGING.own_goals,
  STAGING.goals_scored,
  STAGING.cost_change_event,
  STAGING.minutes,
  STAGING.influence_rank,
  STAGING.value_form,
  STAGING.transfers_out_event,
  STAGING.yellow_cards,
  STAGING.transfers_out,
  STAGING.penalties_order,
  STAGING.transfers_in_event,
  STAGING.event_points,
  STAGING.assists,
  STAGING.total_points,
  STAGING.saves,
  STAGING.creativity_rank,
  STAGING.threat_rank_type,
  STAGING.points_per_game,
  STAGING.now_cost,
  STAGING.in_dreamteam,
  STAGING.red_cards,
  STAGING.goals_conceded,
  STAGING.news,
  STAGING.news_added,
  STAGING.bonus,
  STAGING.form,
  STAGING.creativity,
  STAGING.cost_change_start_fall,
  STAGING.ict_index,
  STAGING.chance_of_playing_this_round,
  STAGING.creativity_rank_type,
  STAGING.cost_change_start,
  STAGING.direct_freekicks_order,
  STAGING.dreamteam_count,
  STAGING.chance_of_playing_next_round,
  STAGING.selected_by_percent,
  STAGING.transfers_in,
  STAGING.clean_sheets,
  STAGING.ep_next,
  STAGING.value_season,
  STAGING.corners_and_indirect_freekicks_order,
  STAGING.influence,
  STAGING.penalties_missed,
  STAGING.ep_this,
  STAGING.source_date
FROM `fantasy_premier_league.staging_fantasy_premierleague_api_bootstrapstatic_elements` AS STAGING
INNER JOIN (
  SELECT MAP.player_id_source,DIM.player_sk,DIM.player_id,DIM.start_date,DIM.end_date,DIM.is_current
  FROM `fantasy_premier_league.metadata_player_id_elements_id_map` AS MAP
  INNER JOIN `fantasy_premier_league.dim_player` AS DIM
  ON MAP.player_id=DIM.player_id
  AND MAP.is_current=true
) AS MAP_PLAYER
ON 
  STAGING.id=MAP_PLAYER.player_id_source
  AND STAGING.source_date<=MAP_PLAYER.end_date
  AND STAGING.source_date>=MAP_PLAYER.start_date
INNER JOIN (
  SELECT MAP.team_id_source,DIM.team_sk,DIM.team_id,DIM.start_date,DIM.end_date,DIM.is_current
  FROM `fantasy_premier_league.metadata_team_id_teams_code_map` AS MAP
  INNER JOIN `fantasy_premier_league.dim_team` AS DIM
  ON MAP.team_id=DIM.team_id
) AS MAP_TEAM
ON 
  STAGING.team_code=MAP_TEAM.team_id_source
  AND STAGING.source_date<=MAP_TEAM.end_date
  AND STAGING.source_date>=MAP_TEAM.start_date
INNER JOIN `fantasy_premier_league.metadata_position_id_element_type_map` AS MAP_POSITION
ON 
  STAGING.element_type=MAP_POSITION.position_id_source
  AND STAGING.source_date<=MAP_POSITION.end_date
  AND STAGING.source_date>=MAP_POSITION.start_date
WHERE 
  STAGING.source_date=run_date
;
END