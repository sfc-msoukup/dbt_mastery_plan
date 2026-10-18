with days as (
    select row_number() over (order by seq4()) -1 as n
    from table(generator(rowcount => 10000))
),

spine as (
    select dateadd(day, n, '2014-11-01'::date) as date_day
    from days
    where dateadd(day, n, '2014-11-01'::date) < current_date()
),

observations as (
    select * from {{ ref('stg_fred__observations') }}
),

wide as (
    select
        spine.date_day as rate_date,
        max(case when observations.series_id = 'DFF' then observations.value end) as dff,
        max(case when observations.series_id = 'DGS10' then observations.value end) as dgs10,
        max(case when observations.series_id = 'CPIAUCSL' then observations.value end) as cpiaucsl
    from spine
    left join observations
        on observations.observation_date = spine.date_day
    group by spine.date_day
),

filled as (
    select
        rate_date,
        last_value(dff ignore nulls) over (
            order by rate_date rows between unbounded preceding and current row
        ) as dff,
        last_value(dgs10 ignore nulls) over (
            order by rate_date rows between unbounded preceding and current row
        ) as dgs10,
        last_value(cpiaucsl ignore nulls) over (
            order by rate_date rows between unbounded preceding and current row
        ) as cpiaucsl
    from wide
)

select * from filled