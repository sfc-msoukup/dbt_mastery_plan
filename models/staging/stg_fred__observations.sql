with source as (
    select * from {{ source('raw', 'fred_observations')}}
),

cleaned as (
    select 
        series_id,
        observation_date,
        try_to_double(nullif(value,'')) as value
    from source
)

select * from cleaned
where value is not null