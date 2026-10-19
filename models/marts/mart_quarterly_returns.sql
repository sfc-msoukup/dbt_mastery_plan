with daily as (
    select * from {{ ref('fct_daily_asset_returns') }}
),

by_quarter as (
    select
        asset_code,
        date_trunc('quarter', price_date)::date as quarter_start,
        count(*)                                as trading_days,
        exp(sum(ln(1 + daily_return)))-1        as quarterly_return,
        avg(fed_funds_rate_pct)                 as avg_fed_funds_rate_pct
    from daily
    group by 1, 2
)

select 
    by_quarter.*,
    assets.asset_name,
    assets.asset_class
from by_quarter
inner join {{ ref('assets') }} as assets
    on assets.asset_code = by_quarter.asset_code