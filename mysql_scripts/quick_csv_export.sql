/* replace with correct table for export*/
SELECT * FROM exports.final_1

/*change to a relevant outfile name*/
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/us_accounts.csv' 

FIELDS TERMINATED BY ',' ENCLOSED BY '"'
ESCAPED BY ''
LINES TERMINATED BY '\r\n';
