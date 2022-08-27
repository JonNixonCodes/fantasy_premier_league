/*
Stored procedure to backfill data from staging to table: dim_player

Usage:
CALL `fantasy_premier_league.sp_backfill_dim_player`(DATE '2022-08-02',DATE '2022-08-26')

Author:
Jonathan Yu
*/
-- Set which start and end dates to backfill the data
CREATE OR REPLACE PROCEDURE `fantasy_premier_league.sp_backfill_dim_player`(start_date DATE,end_date DATE)
BEGIN
DECLARE run_date DATE;
SET run_date = start_date;
-- loop for each run_date between start_date and end_date
WHILE run_date <= end_date DO
  -- execute upsert stored procedure
  CALL `fantasy_premier_league.sp_upsert_dim_player`(run_date);
  -- increment run_date
  set run_date=run_date+1;
END WHILE;

END