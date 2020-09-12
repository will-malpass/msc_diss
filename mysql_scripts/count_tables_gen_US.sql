
/*group participation count*/
CREATE TABLE tallies.group_count AS 
SELECT steamid,
COUNT(groupid)
FROM sdb.groups
GROUP BY steamid;

ALTER TABLE `tallies`.`group_count` 
CHANGE COLUMN `COUNT(groupid)` `group_connections` BIGINT NOT NULL DEFAULT '0'; /*renaming columns to avoid later merge conflicts*/

/*total game count, including paid (and f2p taken as the difference between the two)*/
CREATE TABLE tallies.total_game_count AS 
SELECT steamid,
COUNT(appid)
FROM sdb.games_2
GROUP BY steamid;

ALTER TABLE `tallies`.`total_game_count` 
CHANGE COLUMN `COUNT(appid)` `total_games_count` BIGINT NOT NULL DEFAULT '0'; /*renaming columns to avoid later merge conflicts*/

/*generating table for games owned which have been paid for - US only*/

CREATE TABLE sdb.accounts_games_at_release_valuation_us AS
	SELECT 
    sdb.games_2.steamid, sdb.games_2.appid, sdb.games_2.playtime_forever,
    sdb.app_id_info.Price,
    sdb.player_summaries.loccountrycode
	FROM
	sdb.games_2
    INNER JOIN sdb.app_id_info
    ON sdb.games_2.appid = sdb.app_id_info.appid
    INNER JOIN sdb.player_summaries
    ON sdb.games_2.steamid = sdb.player_summaries.steamid
    
    WHERE sdb.app_id_info.Price != '0'
    AND sdb.player_summaries.loccountrycode = 'US';
    

/*total hours played count, across all game types and then excluding free games*/
CREATE TABLE tallies.total_hours_played AS 
SELECT steamid,
SUM(playtime_forever)
FROM sdb.games_2
GROUP BY steamid;
ALTER TABLE `tallies`.`total_hours_played` 
CHANGE COLUMN `SUM(playtime_forever)` `total_hours_played` BIGINT NOT NULL DEFAULT '0'; /*renaming columns to avoid later merge conflicts*/

/*run from here*/

/*total hours played excluding free games*/
CREATE TABLE tallies.total_hours_played_paid AS 
SELECT steamid,
SUM(playtime_forever)
FROM sdb.accounts_games_at_release_valuation_us
GROUP BY steamid;

ALTER TABLE `tallies`.`total_hours_played_paid` 
CHANGE COLUMN `SUM(playtime_forever)` `total_hours_played_paid` BIGINT NOT NULL DEFAULT '0'; /*renaming columns to avoid later merge conflicts*/

/*total account worth*/
CREATE TABLE tallies.total_account_worth AS 
SELECT steamid,
SUM(Price)
FROM sdb.accounts_games_at_release_valuation_us
GROUP BY steamid;

ALTER TABLE `tallies`.`total_account_worth` 
CHANGE COLUMN `SUM(Price)` `total_account_worth` BIGINT NOT NULL DEFAULT '0'; /*renaming columns to avoid later merge conflicts*/

/*total game count paid*/
CREATE TABLE tallies.total_game_count_paid AS 
SELECT steamid,
COUNT(appid)
FROM sdb.accounts_games_at_release_valuation_us
GROUP BY steamid;

ALTER TABLE `tallies`.`total_game_count_paid` 
CHANGE COLUMN `COUNT(appid)` `total_game_count_paid` BIGINT NOT NULL DEFAULT '0'; /*renaming columns to avoid later merge conflicts*/
