
with 
ref as (
    select * from {{ ref('base__observation') }}
)

select distinct key_name from ref