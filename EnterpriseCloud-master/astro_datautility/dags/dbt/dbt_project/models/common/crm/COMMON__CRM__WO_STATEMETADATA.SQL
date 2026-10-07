{{ config(
        alias = 'WO_STATEMETADATA',
        materialized='incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as (
    select
        ENTITYNAME,
        STATE,
        ISUSERLOCALIZEDLABEL,
        LOCALIZEDLABELLANGUAGECODE,
        LOCALIZEDLABEL
    from {{ ref('ODS__CRM_FILE__STATEMETADATA') }}
),

transform_data as (
    select
        ENTITYNAME,
        STATE,
        ISUSERLOCALIZEDLABEL,
        LOCALIZEDLABELLANGUAGECODE,
        LOCALIZEDLABEL,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH -- Adds column to table on full refresh.
    from source_data
),

type_data as (
    select
        cast(ENTITYNAME as VARCHAR(16777216)) as ENTITYNAME,
        cast(STATE as NUMBER(38,0)) as STATE,
        cast(ISUSERLOCALIZEDLABEL as BOOLEAN) as ISUSERLOCALIZEDLABEL,
        cast(LOCALIZEDLABELLANGUAGECODE as NUMBER(38,0)) as LOCALIZEDLABELLANGUAGECODE,
        cast(LOCALIZEDLABEL as VARCHAR(16777216)) as LOCALIZEDLABEL,
        cast(AUDIT_LOG_ID as VARCHAR(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH
    from transform_data
)

select * from type_data