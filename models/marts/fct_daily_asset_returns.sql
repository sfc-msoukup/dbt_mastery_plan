with cte_returns as (
    select * from {{ ref('int_crypto__daily_returns') }}
    where daily_return is not null
),

rates as (
    select * from {{ ref('int_macro__daily_rates') }}
)

select
    cte_returns.asset_code,
    cte_returns.price_date,
    cte_returns.close_usd,
    cte_returns.daily_return,
    rates.dff               as fed_funds_rate_pct,
    rates.dgs10             as treasury_10y_pct,
    cte_returns.daily_return - rates.dff / 100 / 365 as excess_return
from cte_returns
left join rates
    on rates.rate_date = cte_returns.price_date
