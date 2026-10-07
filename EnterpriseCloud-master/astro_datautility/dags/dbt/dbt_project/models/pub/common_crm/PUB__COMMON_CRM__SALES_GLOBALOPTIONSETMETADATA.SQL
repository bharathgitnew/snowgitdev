{{ config(
        materialized = 'view',
        alias = 'SALES_GLOBALOPTIONSETMETADATA',
        transient = 'false'
) }}

with source_data as (
    select 
    OPTIONSETNAME, 
 	OPTION, 
 	ISUSERLOCALIZEDLABEL, 
 	LOCALIZEDLABELLANGUAGECODE, 
 	LOCALIZEDLABEL
    FROM {{ ref('COMMON__CRM__SALES_GLOBALOPTIONSETMETADATA') }}
),

transform_data as (
    SELECT * FROM source_data
)

SELECT * FROM transform_data