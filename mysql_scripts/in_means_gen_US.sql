/* generate random sample (n=5000) */
CREATE TABLE in_means.sample_25k AS
SELECT * FROM exports.final_1 
WHERE rand() <= .3
AND locstatecode != 'NULL'
LIMIT 5000;

CREATE TABLE in_means.friends_b AS
	SELECT 
    in_means.sample_25k.steamid,
	networks.us_connections.steamid_b
	FROM
	in_means.sample_25k
	LEFT JOIN networks.us_connections
    ON in_means.sample_25k.steamid = networks.us_connections.steamid;

ALTER TABLE `in_means`.`friends_b` 
CHANGE COLUMN `steamid` `original` BIGINT UNSIGNED NULL DEFAULT NULL ;

CREATE TABLE in_means.nodupe1 LIKE in_means.friends_b;
INSERT in_means.nodupe1 SELECT DISTINCT * FROM in_means.friends_b;

DROP TABLE `in_means`.`friends_b`;

ALTER TABLE `in_means`.`nodupe1` 
RENAME TO  `in_means`.`friends_b` ;


CREATE TABLE in_means.friends_info AS
	SELECT 
    in_means.friends_b.original, in_means.friends_b.steamid_b,
    sdb.games_2.steamid, sdb.games_2.appid, sdb.games_2.playtime_forever
	FROM
	in_means.friends_b
	INNER JOIN sdb.games_2
    ON in_means.friends_b.steamid_b = sdb.games_2.steamid;


CREATE TABLE in_means.friends_valuations AS
	SELECT 
    in_means.friends_info.original, in_means.friends_info.steamid_b, in_means.friends_info.appid, in_means.friends_info.playtime_forever,
    sdb.app_id_info.Price
    FROM
    in_means.friends_info
    INNER JOIN sdb.app_id_info
    ON in_means.friends_info.appid = sdb.app_id_info.appid
        WHERE sdb.app_id_info.Price != '0';
        
/*tallies*/

/*total hours played excluding free games*/
CREATE TABLE in_means.total_hours_played AS 
SELECT steamid_b,
SUM(playtime_forever)
FROM in_means.friends_valuations
GROUP BY steamid_b;


/*total account worth*/
CREATE TABLE in_means.total_account_worth AS 
SELECT steamid_b,
SUM(Price)
FROM in_means.friends_valuations
GROUP BY steamid_b;


ALTER TABLE `in_means`.`total_hours_played` 
CHANGE COLUMN `SUM(playtime_forever)` `total_hours_played_paid_friends` BIGINT NOT NULL DEFAULT '0'; /*renaming columns to avoid later merge conflicts*/

ALTER TABLE `in_means`.`total_account_worth` 
CHANGE COLUMN `SUM(Price)` `total_account_worth_friends` BIGINT NOT NULL DEFAULT '0'; /*renaming columns to avoid later merge conflicts*/

/*sample of 5000 users generated a dataset of 60921 further users*/


CREATE TABLE in_means.friends_tallied AS
	SELECT 
    in_means.friends_b.original, in_means.friends_b.steamid_b,
    in_means.total_hours_played.total_hours_played_paid_friends,
    in_means.total_account_worth.total_account_worth_friends
    FROM 
    in_means.friends_b
    INNER JOIN in_means.total_hours_played
    ON in_means.friends_b.steamid_b=in_means.total_hours_played.steamid_b
    INNER JOIN in_means.total_account_worth
    ON in_means.friends_b.steamid_b=in_means.total_account_worth.steamid_b;
    
/*remove duplicates - very many of these, assign unique index in the future for these sort of merges to avoid duplicates*/
CREATE TABLE in_means.nodupe LIKE in_means.friends_tallied;
INSERT in_means.nodupe SELECT DISTINCT * FROM in_means.friends_tallied;
    

CREATE TABLE in_means.network_stats_1 AS
	SELECT original,
    AVG(total_hours_played_paid_friends)
    FROM in_means.nodupe
    GROUP BY original;    

CREATE TABLE in_means.network_stats_2 AS
	SELECT original,
    AVG(total_account_worth_friends)
    FROM in_means.nodupe
    GROUP BY original;
    
ALTER TABLE `in_means`.`network_stats_1` 
CHANGE COLUMN `AVG(total_hours_played_paid_friends)` `average_hours_played_paid_friends` BIGINT NOT NULL DEFAULT '0'; /*renaming columns to avoid later merge conflicts*/

ALTER TABLE `in_means`.`network_stats_2` 
CHANGE COLUMN `AVG(total_account_worth_friends)` `average_account_worth_friends` BIGINT NOT NULL DEFAULT '0'; /*renaming columns to avoid later merge conflicts*/


    
CREATE TABLE exports.final_in_means AS 
	SELECT 
    in_means.network_stats_1.original, in_means.network_stats_1.average_hours_played_paid_friends,
    in_means.network_stats_2.average_account_worth_friends,
    exports.final_1.*
    FROM in_means.network_stats_1
    INNER JOIN in_means.network_stats_2
    ON in_means.network_stats_1.original = in_means.network_stats_2.original
    LEFT JOIN exports.final_1
    ON in_means.network_stats_1.original = exports.final_1.steamid;    

/*export*/
SELECT * FROM exports.final_in_means
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/in_means_sample.csv' 
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
ESCAPED BY ''
LINES TERMINATED BY '\r\n';
