-- 1. A home for the project, and a small warehouse that suspends itself
CREATE DATABASE IF NOT EXISTS DBT_MASTERY_LAB;
CREATE SCHEMA IF NOT EXISTS DBT_MASTERY_LAB.RAW;
CREATE WAREHOUSE IF NOT EXISTS DBT_LAB_WH
  WAREHOUSE_SIZE = 'XSMALL' AUTO_SUSPEND = 60 AUTO_RESUME = TRUE INITIALLY_SUSPENDED = TRUE;
USE WAREHOUSE DBT_LAB_WH;
USE SCHEMA DBT_MASTERY_LAB.RAW;

-- 2. Describe the two file shapes.
--    CryptoDataDownload puts a URL on line 1 and the header on line 2 -> skip 2.
CREATE OR REPLACE FILE FORMAT cdd_csv  TYPE = CSV SKIP_HEADER = 2 FIELD_OPTIONALLY_ENCLOSED_BY = '"';
CREATE OR REPLACE FILE FORMAT fred_csv TYPE = CSV SKIP_HEADER = 1;
CREATE OR REPLACE STAGE landing;

-- 3. Landing tables: raw values plus two audit columns (which file, when loaded)
CREATE OR REPLACE TABLE crypto_ohlcv (
  unix_ts NUMBER, trade_ts TIMESTAMP_NTZ, symbol VARCHAR,
  open FLOAT, high FLOAT, low FLOAT, close FLOAT, volume_base FLOAT, volume_usd FLOAT,
  _file VARCHAR, _loaded_at TIMESTAMP_LTZ);
CREATE OR REPLACE TABLE fred_observations (
  series_id VARCHAR, observation_date DATE, value VARCHAR,   -- VARCHAR on purpose: gaps arrive as ''
  _file VARCHAR, _loaded_at TIMESTAMP_LTZ);

-- 4. Upload the five files to the stage, then load. Either:
--    a) Snowsight: Ingestion > Add Data > Load files into a Stage, pick
--       DBT_MASTERY_LAB.RAW.LANDING, path crypto/ or fred/ (250 MB per file max), or
--    b) Snowflake CLI (snow sql) from your laptop:
-- PUT 'file:///path/to/Bitstamp_*.csv' @landing/crypto/;
-- PUT 'file:///path/to/fred_*.csv'     @landing/fred/;
-- snow stage copy 'Bitstamp_*.csv' @landing/crypto/;
-- snow stage copy 'fred_*.csv' @landing/fred/;

-- VERIFY:
ls @DBT_MASTERY_LAB.RAW.LANDING/crypto;
ls @DBT_MASTERY_LAB.RAW.LANDING/fred;

COPY INTO crypto_ohlcv FROM (
  SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9, METADATA$FILENAME, CURRENT_TIMESTAMP()
  FROM @landing/crypto/) FILE_FORMAT = (FORMAT_NAME = 'cdd_csv');
COPY INTO fred_observations FROM (
  SELECT REGEXP_SUBSTR(METADATA$FILENAME, 'fred_([A-Z0-9]+)\\.csv', 1, 1, 'e'),  -- series id from file name
         $1, $2, METADATA$FILENAME, CURRENT_TIMESTAMP()
  FROM @landing/fred/) FILE_FORMAT = (FORMAT_NAME = 'fred_csv');

-- 5. The role dbt runs as. It reads RAW and creates its own schemas; nothing more.
CREATE ROLE IF NOT EXISTS TRANSFORMER;
GRANT USAGE ON WAREHOUSE DBT_LAB_WH TO ROLE TRANSFORMER;
GRANT USAGE, CREATE SCHEMA ON DATABASE DBT_MASTERY_LAB TO ROLE TRANSFORMER;
GRANT USAGE ON SCHEMA DBT_MASTERY_LAB.RAW TO ROLE TRANSFORMER;
GRANT SELECT ON ALL TABLES IN SCHEMA DBT_MASTERY_LAB.RAW TO ROLE TRANSFORMER;
GRANT SELECT ON FUTURE TABLES IN SCHEMA DBT_MASTERY_LAB.RAW TO ROLE TRANSFORMER;  -- tables you add later
GRANT ROLE TRANSFORMER TO USER <your_user>;