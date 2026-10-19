with daily as (
    select * from {{ ref('fct_daily_asset_returns') }}
),

bounds as (
    select
        asset_code,
        date_trunc('quarter', price_date)::date as quarter_start,
        max_by(close_usd, price_date)           as last_close,
        min_by(close_usd / (1 + daily_return), price_date) as prior_close
    from daily
    group by 1, 2
)

select
    bounds.asset_code,
    bounds.quarter_start,
    mart.quarterly_return,
    bounds.last_close / bounds.prior_close - 1 as price_based_return
from bounds
inner join {{ ref('mart_quarterly_returns') }} as mart
    using (asset_code, quarter_start)
where abs(mart.quarterly_return - (bounds.last_close / bounds.prior_close - 1)) > 1e-9