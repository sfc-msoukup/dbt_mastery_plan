select *
from dbt_mastery_lab.raw.crypto_ohlcv
ORDER BY _LOADED_AT DESC
LIMIT 10;

select *
from dbt_mastery_lab.raw.fred_observations
LIMIT 10;

select *
from dbt_mastery_lab.dbt_mts_staging.stg_crypto__daily_prices
limit 100;

select MAX(_LOADED_AT)
from dbt_mastery_lab.raw.crypto_ohlcv;

with days as (
select row_number() over (order by seq4()) -1 as n
from table(generator(rowcount => 10000)))

select dateadd(day, n, '2014-11-01'::date) as date_day
from days
where dateadd(day, n, '2014-11-01'::date) < current_date();

select *
from dbt_mastery_lab.dbt_mts_intermediate.int_macro__daily_rates;

select *
from dbt_mastery_lab.dbt_mts_marts.mart_quarterly_returns
ORDER BY quarter_start desc;

