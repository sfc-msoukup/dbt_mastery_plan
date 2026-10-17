with prices as (
    select * from {{ref('stg_crypto__daily_prices')}}
)

select
asset_code,
price_date,
close_usd,
(close_usd / nullif(lag(close_usd) over(partition by asset_code order by price_date), 0)-1) as daily_return
from prices