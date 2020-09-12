Run the schema creation script first in prelim folder


All tables derived from the original data in the SQL dump: https://steam.internet.byu.edu/


Run these scripts in the following order to generate the correct tables:
network_effects_gen_US.sql
count_tables_gen_US.sql
in_means_gen_US.sql
rdd_rob_data_gen.sql


Use the script provided in quick_csv_export.sql to export the tables - the in-built export wizard in MySQL is incredibly slow.
