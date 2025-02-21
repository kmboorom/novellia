
with 
ref as (
    select * from {{ ref('base__diagnostic_report') }}
)

select distinct key_name from ref