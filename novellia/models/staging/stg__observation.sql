with 
base as (
    select * from {{ ref('base__observation') }} 
),

pivot as (
    select 
        id,
        {% for key in dbt_utils.get_column_values(table=ref('base_int__observation'), column='key_name') %}
            {% if key != 'id' %}
                jsonb_agg(case when key_name = '{{ key }}' then value end) filter (where key_name = '{{ key }}') as "{{ key }}"{% if not loop.last %},{% endif %}
            {% endif %}
        {% endfor %}
    from base
    group by id
),

final as (

    select 
        id as observation_id,
        replace(
            (jsonb_array_elements(encounter)->'reference'->>0)::text, 
            'Encounter/', 
            ''
        ) as encounter_id,
		replace(
            (jsonb_array_elements("subject")->'reference'->>0)::text, 
            'Patient/', 
            ''
        ) as patient_id,
		REGEXP_REPLACE("resourceType"::text, '^\[|"|\]$', '', 'g') AS resource_type,
        REGEXP_REPLACE("status"::text, '^\[|"|\]$', '', 'g') AS status,
		("effectiveDateTime"->>0)::timestamp as effective_date_time,
		("issued"->>0)::timestamp as issued_date_time,
		jsonb_array_elements(category) -> 0 -> 'coding' -> 0 ->> 'code' as category,
		category as category_raw,
        jsonb_array_elements("code") ->> 'text' as lab_test_name,
        code,
        component,
        meta,
        "valueCodeableConcept" as value_codeabale_concept,
        "valueQuantity" as value_quantity
    from pivot


)

select * from final