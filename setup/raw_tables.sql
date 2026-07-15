-- use correct database and schema
USE ROLE ACCOUNTADMIN;
USE DATABASE SUNMOBILITY_ADVANCED_DB;
USE SCHEMA RAW_DATA;

-- ============================================
-- Table 1: retail_customers
-- stores individual retail customer details
-- ============================================
CREATE OR REPLACE TABLE retail_customers (
    customer_id       VARCHAR(10),
    name              VARCHAR(100),
    phone             VARCHAR(15),
    email             VARCHAR(100),
    city              VARCHAR(50),
    state             VARCHAR(50),
    vehicle_id        VARCHAR(10),
    plan_type         VARCHAR(20),
    registered_date   DATE,
    status            VARCHAR(20)
);

-- ============================================
-- Table 2: fleet_customers
-- stores fleet company subscription details
-- ============================================
CREATE OR REPLACE TABLE fleet_customers (
    fleet_id          VARCHAR(10),
    company_name      VARCHAR(100),
    contact_person    VARCHAR(100),
    phone             VARCHAR(15),
    email             VARCHAR(100),
    city              VARCHAR(50),
    state             VARCHAR(50),
    subscription_plan VARCHAR(20),
    monthly_deposit   FLOAT,
    current_balance   FLOAT,
    vehicle_count     INT,
    registered_date   DATE,
    status            VARCHAR(20)
);

-- ============================================
-- Table 3: stations
-- stores swap station details with GPS
-- ============================================
CREATE OR REPLACE TABLE stations (
    station_id        VARCHAR(10),
    station_name      VARCHAR(100),
    city              VARCHAR(50),
    state             VARCHAR(50),
    region            VARCHAR(20),
    latitude          FLOAT,
    longitude         FLOAT,
    total_docks       INT,
    active_docks      INT,
    status            VARCHAR(20),
    onboarded_date    DATE,
    last_online_date  DATE,
    manager_name      VARCHAR(100),
    manager_phone     VARCHAR(15)
);

-- ============================================
-- Table 4: station_status_log
-- tracks when stations go online or offline
-- ============================================
CREATE OR REPLACE TABLE station_status_log (
    log_id            VARCHAR(10),
    station_id        VARCHAR(10),
    status            VARCHAR(20),
    reason            VARCHAR(200),
    logged_at         TIMESTAMP,
    resolved_at       TIMESTAMP
);

-- ============================================
-- Table 5: station_alerts
-- stores alerts triggered by stations and docks
-- ============================================
CREATE OR REPLACE TABLE station_alerts (
    alert_id          VARCHAR(10),
    station_id        VARCHAR(10),
    dock_id           VARCHAR(10),
    alert_type        VARCHAR(50),
    severity          VARCHAR(20),
    alert_message     VARCHAR(200),
    triggered_at      TIMESTAMP,
    resolved_at       TIMESTAMP,
    status            VARCHAR(20)
);

-- ============================================
-- Table 6: battery_alerts
-- stores alerts triggered by battery issues
-- ============================================
CREATE OR REPLACE TABLE battery_alerts (
    alert_id          VARCHAR(10),
    battery_id        VARCHAR(10),
    station_id        VARCHAR(10),
    alert_type        VARCHAR(50),
    severity          VARCHAR(20),
    alert_message     VARCHAR(200),
    battery_health    FLOAT,
    triggered_at      TIMESTAMP,
    resolved_at       TIMESTAMP,
    status            VARCHAR(20)
);

-- ============================================
-- Table 7: battery_packs
-- stores battery pack details and health
-- ============================================
CREATE OR REPLACE TABLE battery_packs (
    battery_id        VARCHAR(10),
    battery_code      VARCHAR(20),
    capacity_kwh      FLOAT,
    manufacture_date  DATE,
    manufacturer      VARCHAR(50),
    health_percentage FLOAT,
    status            VARCHAR(20),
    cycle_count       INT,
    station_id        VARCHAR(10),
    last_charged_at   TIMESTAMP
);

-- ============================================
-- Table 8: vehicles
-- stores vehicle and owner details
-- ============================================
CREATE OR REPLACE TABLE vehicles (
    vehicle_id        VARCHAR(10),
    vehicle_no        VARCHAR(20),
    customer_id       VARCHAR(10),
    customer_type     VARCHAR(20),
    city              VARCHAR(50),
    state             VARCHAR(50),
    vehicle_type      VARCHAR(20),
    registered_date   DATE,
    status            VARCHAR(20)
);

-- ============================================
-- Table 9: swap_records
-- stores every battery swap event
-- updated every 10 minutes
-- ============================================
CREATE OR REPLACE TABLE swap_records (
    swap_id           VARCHAR(10),
    customer_id       VARCHAR(10),
    customer_type     VARCHAR(20),
    vehicle_id        VARCHAR(10),
    station_id        VARCHAR(10),
    dock_id           VARCHAR(10),
    battery_out       VARCHAR(10),
    battery_in        VARCHAR(10),
    swap_date         DATE,
    swap_time         TIME,
    operator_id       VARCHAR(10),
    amount            FLOAT,
    payment_type      VARCHAR(20),
    payment_status    VARCHAR(20),
    swap_status       VARCHAR(20),
    failure_reason    VARCHAR(100)
);

-- ============================================
-- Table 10: vehicle_live_data
-- stores GPS and battery data every 10 minutes
-- ============================================
CREATE OR REPLACE TABLE vehicle_live_data (
    record_id         VARCHAR(15),
    vehicle_id        VARCHAR(10),
    latitude          FLOAT,
    longitude         FLOAT,
    battery_level     FLOAT,
    speed_kmph        FLOAT,
    ignition_status   VARCHAR(10),
    recorded_at       TIMESTAMP
);

-- verify all 10 tables created
SHOW TABLES IN SCHEMA SUNMOBILITY_ADVANCED_DB.RAW_DATA;