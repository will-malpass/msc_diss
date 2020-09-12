CREATE TABLE exports.tallies as select * from networks.us_tallies;
CREATE TABLE exports.null as select * from networks.us_null;

INSERT INTO exports.tallies
SELECT * FROM exports.null;

CREATE TABLE exports.final_2 AS
	SELECT 
    exports.tallies.steamid, exports.tallies.timecreated, exports.tallies.existing_connections_count, exports.tallies.new_connections_count, exports.tallies.total_connections, 
    tallies.total_account_worth.total_account_worth,
    tallies.total_game_count.total_game_count,
    tallies.total_game_count_paid.total_game_count_paid,
    tallies.total_hours_played.total_hours_played,
    tallies.total_hours_played_paid.total_hours_played_paid,
    tallies.group_count.group_connections,
    sdb.player_summaries.locstatecode
    FROM exports.tallies
    INNER JOIN tallies.total_account_worth
    ON exports.tallies.steamid=tallies.total_account_worth.steamid
    INNER JOIN tallies.total_game_count
    ON exports.tallies.steamid=tallies.total_game_count.steamid
    INNER JOIN tallies.total_game_count_paid
    ON exports.tallies.steamid=tallies.total_game_count_paid.steamid
    INNER JOIN tallies.total_hours_played
    ON exports.tallies.steamid=tallies.total_hours_played.steamid
    INNER JOIN tallies.total_hours_played_paid
    ON exports.tallies.steamid=tallies.total_hours_played_paid.steamid
    LEFT JOIN tallies.group_count
    ON exports.tallies.steamid=tallies.group_count.steamid
    LEFT JOIN sdb.player_summaries
    ON exports.tallies.steamid=sdb.player_summaries.steamid;

/*ready for export*/
