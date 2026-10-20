with prices as (
    select * from {{ref('stg_crypto__daily_prices')}}
)

select
asset_code,
price_date,
close_usd,
{{ pct_change('close_usd', 'asset_code', 'price_date') }} as daily_return
from prices