with source as ( 
    select 
        data ->> 'id' as id,
        data
    from {{ source('raw', 'patient') }} 
),

keys_per_row as (
    select 
        id,
        jsonb_object_keys(data) as key_name
    from source
),

final as (
    select distinct
        s.id,
        k.key_name,
        s.data -> k.key_name as value
    from source s
    join keys_per_row k on s.id = k.id
)

select * from final