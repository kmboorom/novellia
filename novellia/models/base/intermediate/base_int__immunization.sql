
with 
ref as (
    select * from {{ ref('base__immunization') }}
)

select distinct key_name from ref