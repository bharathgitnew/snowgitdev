{{ config(
       materialized='tel_incremental'  ,
    incremental_strategy='insert_overwrite',
        tags=["insert_overwrite_tea_logistics"],
    alias='ROP_SS_CROSSTAB'  
) }}

{%- set columns_to_show = "material,plant,Local_ABC,Intel_ABC,Product_Code,CONSUMABLE,Narita_ABC,Criticality_Score" -%}
{%- set pivot_column = "storage_location" -%}
{%- set aggregate_columns="ROP","SS","MAX" -%}


{%- set my_query -%}
SELECT DISTINCT {{pivot_column}} FROM {{ ref('GOLD__TEA_LOGISTICS__ROP_SS_REPORT') }};
{%- endset -%}

{%- set results = run_query(my_query) -%}

{%- if execute -%}
{%- set items = results.columns[0].values() -%}
{%- endif -%}
with source_data as
(
SELECT {{columns_to_show}},
{%- for i in items %}
sum("{{i}}_ROP") AS "{{i}}_ROP",
sum("{{i}}_ROP") AS "{{i}}_SS",
sum("{{i}}_ROP") AS "{{i}}_MAX"
{%- if not loop.last %}, {% endif -%}
{%- endfor %}
FROM (
        SELECT {{columns_to_show}},
        {%- for i in items %}
        CASE WHEN {{pivot_column}} = '{{i}}' THEN {{aggregate_columns[0]}} ELSE 0 END as "{{i}}_ROP",
        CASE WHEN {{pivot_column}} = '{{i}}' THEN {{aggregate_columns[1]}} ELSE 0 END as "{{i}}_SS",
        CASE WHEN {{pivot_column}} = '{{i}}' THEN {{aggregate_columns[2]}} ELSE 0 END as "{{i}}_MAX"
        {%- if not loop.last %}, {% endif -%}
        {%- endfor %}
        FROM {{ ref('GOLD__TEA_LOGISTICS__ROP_SS_REPORT') }} )
    GROUP BY {{columns_to_show}}
),
transform_data AS
(
    select 
        * 
    from source_data
),
type_data as (
    SELECT 
        CAST('{{ invocation_id }}' AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(SHA2('hash_me') AS VARCHAR(128)) AS _ROW_HASH,
        *
    from transform_data
)
select * from type_data