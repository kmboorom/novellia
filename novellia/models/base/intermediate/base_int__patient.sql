
with 
ref as (
    select * from {{ ref('base__patient') }}
)

select distinct key_name from ref