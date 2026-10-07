{{ config(
        alias = 'OPTIONSET_METADATA',
        materialized = 'view',
        transient = 'false'
) }}

with source_data as (
    SELECT 
        ENTITYNAME,
        OPTIONSETNAME, 
        OPTION, 
        ISUSERLOCALIZEDLABEL, 
        LOCALIZEDLABELLANGUAGECODE, 
        LOCALIZEDLABEL,
        SOURCE_FLAG
    FROM {{ ref('COMMON__CRM__OPTIONSET_METADATA') }}
),

transform_data as (
    SELECT * FROM source_data
)

SELECT * FROM transform_data