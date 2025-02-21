with 
extract as (
    select 
        vaccine_code->0->>'text' as vc_name,
        * 
    from {{ref('stg__immunization')}}
),

vaccine_cnts as (

select count(distinct patient_id) as vc_count,
vc_name
 from extract

group by 2

)

select * from vaccine_cnts