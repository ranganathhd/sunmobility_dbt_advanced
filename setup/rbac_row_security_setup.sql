USE ROLE ACCOUNTADMIN;
USE DATABASE SUNMOBILITY_ADVANCED_DB;

-- ============================================
-- Step 1: Create Roles
-- ============================================

-- analyst role — read only access to mart tables
CREATE ROLE IF NOT EXISTS ANALYST_ROLE;

-- data engineer role — full access everywhere
CREATE ROLE IF NOT EXISTS DATA_ENGINEER_ROLE;

-- fleet analyst role — sees only their own fleet data
CREATE ROLE IF NOT EXISTS FLEET_ANALYST_ROLE;

-- ============================================
-- Step 2: Grant Warehouse Access
-- ============================================

-- all roles need warehouse to run queries
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE ANALYST_ROLE;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE DATA_ENGINEER_ROLE;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE FLEET_ANALYST_ROLE;

-- ============================================
-- Step 3: Grant Database Access
-- ============================================

GRANT USAGE ON DATABASE SUNMOBILITY_ADVANCED_DB TO ROLE ANALYST_ROLE;
GRANT USAGE ON DATABASE SUNMOBILITY_ADVANCED_DB TO ROLE DATA_ENGINEER_ROLE;
GRANT USAGE ON DATABASE SUNMOBILITY_ADVANCED_DB TO ROLE FLEET_ANALYST_ROLE;

-- ============================================
-- Step 4: Grant Schema Access
-- ============================================

-- analyst sees only marts schema
GRANT USAGE ON SCHEMA SUNMOBILITY_ADVANCED_DB.DBT_DEV_DBT_MARTS TO ROLE ANALYST_ROLE;
GRANT USAGE ON SCHEMA SUNMOBILITY_ADVANCED_DB.DBT_DEV_DBT_MARTS TO ROLE FLEET_ANALYST_ROLE;

-- data engineer sees all schemas
GRANT USAGE ON ALL SCHEMAS IN DATABASE SUNMOBILITY_ADVANCED_DB TO ROLE DATA_ENGINEER_ROLE;

-- ============================================
-- Step 5: Grant Table Access
-- ============================================

-- analyst gets SELECT only on mart tables
GRANT SELECT ON ALL TABLES IN SCHEMA SUNMOBILITY_ADVANCED_DB.DBT_DEV_DBT_MARTS TO ROLE ANALYST_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA SUNMOBILITY_ADVANCED_DB.DBT_DEV_DBT_MARTS TO ROLE FLEET_ANALYST_ROLE;

-- data engineer gets full access
GRANT ALL ON ALL TABLES IN DATABASE SUNMOBILITY_ADVANCED_DB TO ROLE DATA_ENGINEER_ROLE;
GRANT ALL ON FUTURE TABLES IN DATABASE SUNMOBILITY_ADVANCED_DB TO ROLE DATA_ENGINEER_ROLE;

-- ============================================
-- Step 6: Create Users
-- ============================================

CREATE USER IF NOT EXISTS ANALYST_USER
    PASSWORD             = 'Analyst@123'
    DEFAULT_ROLE         = ANALYST_ROLE
    MUST_CHANGE_PASSWORD = FALSE;

CREATE USER IF NOT EXISTS FLEET_ANALYST_USER
    PASSWORD             = 'Fleet@123'
    DEFAULT_ROLE         = FLEET_ANALYST_ROLE
    MUST_CHANGE_PASSWORD = FALSE;

-- ============================================
-- Step 7: Assign Roles to Users
-- ============================================

GRANT ROLE ANALYST_ROLE       TO USER ANALYST_USER;
GRANT ROLE ANALYST_ROLE       TO USER AUTOMATIONUSER;
GRANT ROLE FLEET_ANALYST_ROLE TO USER FLEET_ANALYST_USER;
GRANT ROLE DATA_ENGINEER_ROLE TO USER AUTOMATIONUSER;

-- verify roles created
SHOW ROLES;






USE ROLE ACCOUNTADMIN;
USE DATABASE SUNMOBILITY_ADVANCED_DB;

-- ============================================
-- Email masking policy
-- analysts see ****@gmail.com
-- data engineers see full email
-- ============================================
CREATE OR REPLACE MASKING POLICY email_mask AS
    (val VARCHAR) RETURNS VARCHAR ->
    CASE
        WHEN CURRENT_ROLE() IN ('DATA_ENGINEER_ROLE', 'ACCOUNTADMIN') THEN val
        ELSE CONCAT('****@', SPLIT_PART(val, '@', 2))
    END;

-- ============================================
-- Phone masking policy
-- analysts see XXXXXX1234 (last 4 digits only)
-- data engineers see full phone
-- ============================================
CREATE OR REPLACE MASKING POLICY phone_mask AS
    (val VARCHAR) RETURNS VARCHAR ->
    CASE
        WHEN CURRENT_ROLE() IN ('DATA_ENGINEER_ROLE', 'ACCOUNTADMIN') THEN val
        ELSE CONCAT('XXXXXX', RIGHT(val, 4))
    END;

-- ============================================
-- Apply masking on dim_retail_customers
-- ============================================
ALTER TABLE SUNMOBILITY_ADVANCED_DB.DBT_DEV_DBT_MARTS.dim_retail_customers
    MODIFY COLUMN email SET MASKING POLICY email_mask;

ALTER TABLE SUNMOBILITY_ADVANCED_DB.DBT_DEV_DBT_MARTS.dim_retail_customers
    MODIFY COLUMN phone SET MASKING POLICY phone_mask;

-- ============================================
-- Apply masking on dim_fleet_customers
-- ============================================
ALTER TABLE SUNMOBILITY_ADVANCED_DB.DBT_DEV_DBT_MARTS.dim_fleet_customers
    MODIFY COLUMN email SET MASKING POLICY email_mask;

ALTER TABLE SUNMOBILITY_ADVANCED_DB.DBT_DEV_DBT_MARTS.dim_fleet_customers
    MODIFY COLUMN phone SET MASKING POLICY phone_mask;

-- verify masking policies
SHOW MASKING POLICIES;




----------------------row level security -----------------------------------

USE ROLE ACCOUNTADMIN;
USE DATABASE SUNMOBILITY_ADVANCED_DB;

-- ============================================
-- Create Row Access Policy
-- FLEET_ANALYST_ROLE sees only their fleet_id
-- All other roles see all rows
-- ============================================
CREATE OR REPLACE ROW ACCESS POLICY fleet_row_policy AS
    (customer_id VARCHAR) RETURNS BOOLEAN ->
    CASE
        -- data engineer and admin see ALL rows
        WHEN CURRENT_ROLE() IN ('DATA_ENGINEER_ROLE', 'ACCOUNTADMIN', 'ANALYST_ROLE') 
        THEN TRUE
        -- fleet analyst sees only rows where customer_id matches their username
        -- in real production: username = fleet company login
        -- for demo: fleet analyst sees only FC001 data
        WHEN CURRENT_ROLE() = 'FLEET_ANALYST_ROLE'
        THEN customer_id = 'FC001'
        ELSE FALSE
    END;

-- ============================================
-- Apply row access policy on fct_swaps
-- only fleet swap rows are filtered
-- ============================================
ALTER TABLE SUNMOBILITY_ADVANCED_DB.DBT_DEV_DBT_MARTS.fct_swaps
    ADD ROW ACCESS POLICY fleet_row_policy ON (customer_id);

-- verify policy applied
SHOW ROW ACCESS POLICIES;


-- ============================================
-- Test 1: As ANALYST_ROLE — should see masked email and phone
-- ============================================
USE ROLE ANALYST_ROLE;

SELECT
    customer_id,
    customer_name,
    email,    -- should show ****@gmail.com
    phone     -- should show XXXXXX1234
FROM SUNMOBILITY_ADVANCED_DB.DBT_DEV_DBT_MARTS.dim_retail_customers
LIMIT 5;

-- ============================================
-- Test 2: As ACCOUNTADMIN — should see full email and phone
-- ============================================
USE ROLE ACCOUNTADMIN;

SELECT
    customer_id,
    customer_name,
    email,    -- should show full email
    phone     -- should show full phone
FROM SUNMOBILITY_ADVANCED_DB.DBT_DEV_DBT_MARTS.dim_retail_customers
LIMIT 5;



USE ROLE ACCOUNTADMIN;

-- grant fleet analyst role to your login user
GRANT ROLE FLEET_ANALYST_ROLE TO USER AUTOMATIONUSER;

-- also grant access to warehouse and schema for this role
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE FLEET_ANALYST_ROLE;
GRANT USAGE ON DATABASE SUNMOBILITY_ADVANCED_DB TO ROLE FLEET_ANALYST_ROLE;
GRANT USAGE ON SCHEMA SUNMOBILITY_ADVANCED_DB.DBT_DEV_DBT_MARTS TO ROLE FLEET_ANALYST_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA SUNMOBILITY_ADVANCED_DB.DBT_DEV_DBT_MARTS TO ROLE FLEET_ANALYST_ROLE;
-- ============================================
-- Test 3: Row Level Security
-- As FLEET_ANALYST_ROLE — should see only FC001 rows
-- ============================================
USE ROLE FLEET_ANALYST_ROLE;

SELECT
    swap_id,
    customer_id,
    customer_type,
    amount
FROM SUNMOBILITY_ADVANCED_DB.DBT_DEV_DBT_MARTS.fct_swaps
WHERE customer_type = 'FLEET'
LIMIT 10;
-- should show only rows where customer_id = FC001

-- ============================================
-- Test 4: As ACCOUNTADMIN — should see ALL fleet rows
-- ============================================
USE ROLE ACCOUNTADMIN;

SELECT
    swap_id,
    customer_id,
    customer_type,
    amount
FROM SUNMOBILITY_ADVANCED_DB.DBT_DEV_DBT_MARTS.fct_swaps
WHERE customer_type = 'FLEET'
LIMIT 10;
-- should show rows from all fleet companies