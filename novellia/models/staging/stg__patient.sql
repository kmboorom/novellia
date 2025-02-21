with 
base as (
    select * from {{ ref('base__immunization') }} 
),

final as (
    select 
        id,
        {% for key in dbt_utils.get_column_values(table=ref('base_int__immunization'), column='key_name') %}
            {% if key != 'id' %}
                jsonb_agg(case when key_name = '{{ key }}' then value end) filter (where key_name = '{{ key }}') as "{{ key }}"{% if not loop.last %},{% endif %}
            {% endif %}
        {% endfor %}
    from base
    group by id
)

select * from final