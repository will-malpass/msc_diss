
CREATE TABLE rdd_rob.p_sums AS 
	SELECT 
    sdb.player_summaries.steamid, sdb.player_summaries.timecreated
    FROM sdb.player_summaries
WHERE sdb.player_summaries.loccountrycode = 'US'
AND sdb.player_summaries.timecreated BETWEEN '2007-01-01' AND '2010-12-12';

CREATE TABLE rdd_rob.p_games AS
	SELECT 
    rdd_rob.p_sums.steamid, rdd_rob.p_sums.timecreated,
    sdb.games_2.appid
    FROM rdd_rob.p_sums
    INNER JOIN sdb.games_2
    ON rdd_rob.p_sums.steamid=sdb.games_2.steamid;

CREATE TABLE rdd_rob.p_value AS
	SELECT 
    rdd_rob.p_games.steamid, rdd_rob.p_games.timecreated, rdd_rob.p_games.appid,
    sdb.app_id_info.Price
    FROM rdd_rob.p_games
    INNER JOIN sdb.app_id_info
    ON rdd_rob.p_games.appid=sdb.app_id_info.appid;
    
    
/*formatting DATETIME to DATE*/
ALTER TABLE rdd_rob.p_value CHANGE timecreated timecreated DATE; 


CREATE TABLE rdd_rob.account_tally_value AS 
SELECT steamid,
SUM(Price)
FROM rdd_rob.p_value
GROUP BY steamid;

ALTER TABLE `rdd_rob`.`account_tally_value` 
CHANGE COLUMN `SUM(Price)` `total_account_worth` BIGINT NOT NULL DEFAULT '0'; /*renaming columns to avoid later merge conflicts*/

CREATE TABLE rdd_rob.accounts_summary AS
	SELECT 
    rdd_rob.account_tally_value.steamid,rdd_rob.account_tally_value.total_account_worth,
    sdb.player_summaries.locstatecode
    FROM rdd_rob.account_tally_value
    INNER JOIN sdb.player_summaries
    ON rdd_rob.account_tally_value.steamid=sdb.player_summaries.steamid
WHERE sdb.player_summaries.locstatecode != 'NULL';

