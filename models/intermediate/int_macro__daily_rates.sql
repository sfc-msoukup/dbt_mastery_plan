with spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2014-11-01' as date)",
        end_date="current_date()"
    ) }}
),

observations as (
    select * from {{ ref('stg_fred__observations') }}
),

wide as (
    select
        spine.date_day as rate_date,
        {% for s in var('fred_series') %}
        max(case when observations.series_id = '{{ s }}' then observations.value end) as {{ s | lower }}
        {%- if not loop.last %},{% endif %}
        {% endfor %}
    from spine
    left join observations
        on observations.observation_date = spine.date_day
    group by spine.date_day
),

filled as (
    select
        rate_date,
        {% for s in var('fred_series') %}
        last_value({{ s | lower }} ignore nulls) over (
            order by rate_date rows between unbounded preceding and current row
        ) as {{ s | lower }}
        {%- if not loop.last %},{% endif %}
        {% endfor %}
    from wide
)

select * from filled