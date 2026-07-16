USE ROLE ACCOUNTADMIN;
USE DATABASE SUNMOBILITY_ADVANCED_DB;
USE SCHEMA RAW_DATA;

-- create storage integration for project 2
-- this securely connects Snowflake to S3
-- uses IAM role instead of hardcoded credentials
CREATE OR REPLACE STORAGE INTEGRATION sunmobility_advanced_s3_integration
    TYPE                      = EXTERNAL_STAGE
    STORAGE_PROVIDER          = S3
    ENABLED                   = TRUE
    STORAGE_AWS_ROLE_ARN      = 'arn:aws:iam::719514706906:role/snowflake-s3-role'
    STORAGE_ALLOWED_LOCATIONS = ('s3://awss3bucketranga-v1/sunmobility-advanced/');

-- get Snowflake IAM details
-- copy STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID
DESC INTEGRATION sunmobility_advanced_s3_integration;




USE ROLE ACCOUNTADMIN;
USE DATABASE SUNMOBILITY_ADVANCED_DB;
USE SCHEMA RAW_DATA;

-- create file format for CSV files
-- tells Snowflake how to read our CSV files
CREATE OR REPLACE FILE FORMAT csv_format
    TYPE                = CSV
    FIELD_DELIMITER     = ','
    SKIP_HEADER         = 1
    NULL_IF             = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL = TRUE;

-- create external stage pointing to S3 bucket
-- uses storage integration — no hardcoded credentials
CREATE OR REPLACE STAGE sunmobility_advanced_stage
    URL                 = 's3://awss3bucketranga-v1/sunmobility-advanced/'
    STORAGE_INTEGRATION = sunmobility_advanced_s3_integration
    FILE_FORMAT         = csv_format;

-- verify stage can see S3 files
LIST @sunmobility_advanced_stage;



--------------pipline ---------------------------------------------------------------

USE ROLE ACCOUNTADMIN;
USE DATABASE SUNMOBILITY_ADVANCED_DB;
USE SCHEMA RAW_DATA;

-- snowpipe for stations — master data
CREATE OR REPLACE PIPE stations_pipe
    AUTO_INGEST = TRUE
AS
COPY INTO stations
FROM @sunmobility_advanced_stage/master/stations.csv
FILE_FORMAT = csv_format;

-- snowpipe for retail customers — master data
CREATE OR REPLACE PIPE retail_customers_pipe
    AUTO_INGEST = TRUE
AS
COPY INTO retail_customers
FROM @sunmobility_advanced_stage/master/retail_customers.csv
FILE_FORMAT = csv_format;

-- snowpipe for fleet customers — master data
CREATE OR REPLACE PIPE fleet_customers_pipe
    AUTO_INGEST = TRUE
AS
COPY INTO fleet_customers
FROM @sunmobility_advanced_stage/master/fleet_customers.csv
FILE_FORMAT = csv_format;

-- snowpipe for vehicles — master data
CREATE OR REPLACE PIPE vehicles_pipe
    AUTO_INGEST = TRUE
AS
COPY INTO vehicles
FROM @sunmobility_advanced_stage/master/vehicles.csv
FILE_FORMAT = csv_format;

-- snowpipe for battery packs — master data
CREATE OR REPLACE PIPE battery_packs_pipe
    AUTO_INGEST = TRUE
AS
COPY INTO battery_packs
FROM @sunmobility_advanced_stage/master/battery_packs.csv
FILE_FORMAT = csv_format;

-- snowpipe for swap records — real time every 10 minutes
CREATE OR REPLACE PIPE swap_records_pipe
    AUTO_INGEST = TRUE
AS
COPY INTO swap_records
FROM @sunmobility_advanced_stage/realtime/swaps/
FILE_FORMAT = csv_format;

-- snowpipe for station alerts — real time every 10 minutes
CREATE OR REPLACE PIPE station_alerts_pipe
    AUTO_INGEST = TRUE
AS
COPY INTO station_alerts
FROM @sunmobility_advanced_stage/realtime/alerts/
FILE_FORMAT = csv_format;

-- snowpipe for battery alerts — real time every 10 minutes
CREATE OR REPLACE PIPE battery_alerts_pipe
    AUTO_INGEST = TRUE
AS
COPY INTO battery_alerts
FROM @sunmobility_advanced_stage/realtime/alerts/
FILE_FORMAT = csv_format;

-- snowpipe for vehicle live data — real time every 10 minutes
CREATE OR REPLACE PIPE vehicle_live_data_pipe
    AUTO_INGEST = TRUE
AS
COPY INTO vehicle_live_data
FROM @sunmobility_advanced_stage/realtime/live/
FILE_FORMAT = csv_format;

-- verify all pipes created
SHOW PIPES;

----------------------- resuming the pipe ---------------------------------

USE ROLE ACCOUNTADMIN;
USE DATABASE SUNMOBILITY_ADVANCED_DB;
USE SCHEMA RAW_DATA;




SELECT SYSTEM$PIPE_STATUS('stations_pipe');


USE ROLE ACCOUNTADMIN;
USE DATABASE SUNMOBILITY_ADVANCED_DB;
USE SCHEMA RAW_DATA;

-- load existing files from S3 into Snowflake
ALTER PIPE stations_pipe          REFRESH;
ALTER PIPE retail_customers_pipe  REFRESH;
ALTER PIPE fleet_customers_pipe   REFRESH;
ALTER PIPE vehicles_pipe          REFRESH;
ALTER PIPE battery_packs_pipe     REFRESH;
ALTER PIPE swap_records_pipe      REFRESH;
ALTER PIPE station_alerts_pipe    REFRESH;
ALTER PIPE battery_alerts_pipe    REFRESH;
ALTER PIPE vehicle_live_data_pipe REFRESH;


-- check all tables have data
SELECT 'stations'          AS table_name, COUNT(*) AS row_count FROM stations
UNION ALL
SELECT 'retail_customers'  AS table_name, COUNT(*) AS row_count FROM retail_customers
UNION ALL
SELECT 'fleet_customers'   AS table_name, COUNT(*) AS row_count FROM fleet_customers
UNION ALL
SELECT 'vehicles'          AS table_name, COUNT(*) AS row_count FROM vehicles
UNION ALL
SELECT 'battery_packs'     AS table_name, COUNT(*) AS row_count FROM battery_packs
UNION ALL
SELECT 'swap_records'      AS table_name, COUNT(*) AS row_count FROM swap_records
UNION ALL
SELECT 'station_alerts'    AS table_name, COUNT(*) AS row_count FROM station_alerts
UNION ALL
SELECT 'battery_alerts'    AS table_name, COUNT(*) AS row_count FROM battery_alerts
UNION ALL
SELECT 'vehicle_live_data' AS table_name, COUNT(*) AS row_count FROM vehicle_live_data;



-- resume all pipes — pipes are paused by default when created


-- verify all pipes are running
SHOW PIPES;