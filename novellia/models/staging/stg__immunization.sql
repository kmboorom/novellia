with 
base as (
    select * from {{ ref('base__immunization') }} 
),

pivot as (
    select 
        id,
        {% for key in dbt_utils.get_column_values(table=ref('base_int__immunization'), column='key_name') %}
            {% if key != 'id' %}
                jsonb_agg(case when key_name = '{{ key }}' then value end) filter (where key_name = '{{ key }}') as "{{ key }}"{% if not loop.last %},{% endif %}
            {% endif %}
        {% endfor %}
    from base
    group by id
),

final as (

    select
        id as immunization_id,
        replace(
            (jsonb_array_elements(patient)->'reference'->>0)::text, 
            'Patient/', 
            ''
        ) AS patient_id,
        REGEXP_REPLACE("primarySource"::text, '^\[|"|\]$', '', 'g') AS primary_source,
        REGEXP_REPLACE("resourceType"::text, '^\[|"|\]$', '', 'g') AS resource_type,
        REGEXP_REPLACE("status"::text, '^\[|"|\]$', '', 'g') AS status,
        ("occurrenceDateTime"->>0)::timestamp as occurrence_date_time,
        encounter,
        location,
        meta,
        "vaccineCode" as vaccine_code
    from pivot


)

select * from final