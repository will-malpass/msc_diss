# All scripts require an SQL environment to function - recommended to install MySQL Server & Workbench (as well as required connector/ODBC), which can be found here:

https://dev.mysql.com/downloads/installer/


Run the schema creation script first in "prelim" folder

# Unpack the SQL dump into "sdb" schema before running scripts

All tables derived from the original data in the SQL dump: https://steam.internet.byu.edu/



Use the script provided in quick_csv_export.sql to export the tables - the in-built export wizard in MySQL is incredibly slow.


## Run these scripts in the following order to generate the correct tables:

network_effects_gen_US.sql

count_tables_gen_US.sql

in_means_gen_US.sql

rdd_rob_data_gen.sql



## Script for generating the final export table for network effects are provided in "final" folder
