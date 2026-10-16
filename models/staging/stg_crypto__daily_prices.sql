with source as (
    select * from {{ source('raw', 'crypto_ohlcv')}}
),

renamed as (
    select
        split_part(symbol, '/', 1) as asset_code,
        trade_ts::date             as price_date,
        open                       as open_usd,
        high                       as high_usd,
        low                        as low_usd,
        close                      as close_usd,
        volume_usd
    from source
)

select * from renamed
WHERE price_date < current_date()