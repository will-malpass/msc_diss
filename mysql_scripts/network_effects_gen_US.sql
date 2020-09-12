
CREATE TABLE networks.us_connections AS 
	SELECT 
    sdb.games_2.steamid, 
    sdb.friends.friend_since, sdb.friends.steamid_b,
    sdb.player_summaries.timecreated
    FROM sdb.games_2
    INNER JOIN sdb.friends
    ON sdb.games_2.steamid=sdb.friends.steamid_a
    INNER JOIN sdb.player_summaries
    ON sdb.games_2.steamid=sdb.player_summaries.steamid
WHERE sdb.player_summaries.loccountrycode = 'US' /*select country code*/
AND sdb.friends.friend_since BETWEEN '2009-01-01' AND '2015-12-12' /*friend data only available from 2009 onwards, connections before this are labelled as being made in 1970*/
AND sdb.player_summaries.timecreated BETWEEN '2009-01-01' AND '2015-12-12';/*cannot compute network effects for accounts created before 2009 - i.e. before friend connections could be pinned down to a specific date */

/*formatting DATETIME to DATE*/
ALTER TABLE networks.us_connections CHANGE timecreated timecreated DATE; 
ALTER TABLE networks.us_connections CHANGE friend_since friend_since DATE;

/*generating connection delta, converting to days*/	
ALTER TABLE networks.us_connections ADD friend_delta INT AS (friend_since-timecreated);
ALTER TABLE networks.us_connections ADD delta_adj INT AS (friend_delta * 0.0365);

/*condition for selecting existing friends, 3 weeks*/
ALTER TABLE networks.us_connections ADD friend_dummy INT AS (CASE WHEN networks.us_connections.delta_adj <22 THEN 1 ELSE 0 END);

/* grouping by steam_id and tallying existing and new connections */
CREATE TABLE networks.us_existing AS 
SELECT steamid, timecreated,
COUNT(friend_dummy)
FROM networks.us_connections
WHERE friend_dummy = '1'
GROUP BY steamid;

CREATE TABLE networks.us_new AS 
SELECT steamid, timecreated,
COUNT(friend_dummy)
FROM networks.us_connections
WHERE friend_dummy = '0'	
GROUP BY steamid;

ALTER TABLE `networks`.`us_existing` 
CHANGE COLUMN `COUNT(friend_dummy)` `existing_connections_count` BIGINT NOT NULL DEFAULT '0'; /*renaming columns to avoid later merge conflicts*/

ALTER TABLE `networks`.`us_new` 
CHANGE COLUMN `COUNT(friend_dummy)` `new_connections_count` BIGINT NOT NULL DEFAULT '0'; /*renaming columns to avoid later merge conflicts*/


/*merging connections together, keeping all obs*/
CREATE TABLE networks.us_tallies AS 
	SELECT 
    networks.us_existing.steamid, networks.us_existing.timecreated, networks.us_existing.existing_connections_count,
    networks.us_new.new_connections_count
    FROM networks.us_existing
    LEFT JOIN networks.us_new
    ON networks.us_existing.steamid=networks.us_new.steamid
    UNION
    SELECT 
    networks.us_existing.steamid, networks.us_existing.timecreated, networks.us_existing.existing_connections_count,
    networks.us_new.new_connections_count
    FROM networks.us_existing
    RIGHT JOIN networks.us_new
	ON networks.us_existing.steamid=networks.us_new.steamid;

ALTER TABLE networks.us_tallies ADD total_connections INT AS (new_connections_count+existing_connections_count);



/*anti-join of friends and player_summaries - i.e. generating a table for users with no connections. CHANGE LOCCOUNTRYCODE FOR DIFFERENT COUNTRIES*/
CREATE TABLE networks.us_null AS
	SELECT
    sdb.player_summaries.steamid, sdb.player_summaries.timecreated
    FROM
    sdb.player_summaries
    
    WHERE sdb.player_summaries.steamid NOT IN (
    SELECT sdb.friends.steamid_a
    FROM sdb.friends)
    
AND player_summaries.loccountrycode = 'US' /*select country code*/
AND sdb.player_summaries.timecreated BETWEEN '2009-01-01' AND '2015-12-12'; /*cannot compute network effects for accounts created before 2009 - i.e. before friend connections could be pinned down to a specific date */

ALTER TABLE networks.us_null 
ADD total_connections INT AS (0),
ADD existing_connections_count INT AS (0),
ADD new_connections_count INT AS (0);


/*anti-join of groups and player_summaries - i.e. generating a table for users with no group connections. CHANGE LOCCOUNTRY CODE FOR DIFFERENT COUNTRIES*/
CREATE TABLE networks.us_null_groups AS
	SELECT
    sdb.player_summaries.steamid, sdb.player_summaries.timecreated
    FROM
    sdb.player_summaries

    WHERE sdb.player_summaries.steamid NOT IN (
    SELECT sdb.groups.steamid
    FROM sdb.groups)
    
AND player_summaries.loccountrycode = 'US' /*select country code*/
AND sdb.player_summaries.timecreated BETWEEN '2009-01-01' AND '2015-12-12'; /*cannot compute network effects for accounts created before 2009 - i.e. before friend connections could be pinned down to a specific date */

ALTER TABLE networks.us_null_groups ADD group_connections INT AS (0);

/*MISC*/
/* innodb_buffer_pool_size needs to be set much higher for this operation (set to 1024M in config file)*/
