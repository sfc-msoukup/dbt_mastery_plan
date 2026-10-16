select *
from dbt_mastery_lab.raw.crypto_ohlcv
LIMIT 10;

select *
from dbt_mastery_lab.raw.fred_observations
LIMIT 10;

select *
from dbt_mastery_lab.dbt_mts_staging.stg_crypto__daily_prices
limit 100;