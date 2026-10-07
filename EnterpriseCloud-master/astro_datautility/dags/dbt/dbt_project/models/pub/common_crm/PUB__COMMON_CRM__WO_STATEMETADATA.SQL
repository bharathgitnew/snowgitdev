{{ config(
        alias = 'WO_STATEMETADATA',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        ENTITYNAME,
        STATE,
        ISUSERLOCALIZEDLABEL,
        LOCALIZEDLABELLANGUAGECODE,
        LOCALIZEDLABEL
    from {{ ref('COMMON__CRM__WO_STATEMETADATA') }} 
)

select * from source_data