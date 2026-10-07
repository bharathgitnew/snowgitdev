{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='SALES_OPTIONSETMETADATA',
    	transient=false
) }}

with source_data as (
select
    ENTITYNAME,
    OPTIONSETNAME,
    OPTION,
    ISUSERLOCALIZEDLABEL,
    LOCALIZEDLABELLANGUAGECODE,
    LOCALIZEDLABEL,
    _FILEDATE,
    _FILENAME
from {{ ref('BRONZE__TEH_EQUIPMENT_SALES__CRM_FILE_OPTIONSETMETADATA') }}
),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        ENTITYNAME,
        OPTIONSETNAME,
        OPTION,
        ISUSERLOCALIZEDLABEL,
        LOCALIZEDLABELLANGUAGECODE,
        LOCALIZEDLABEL,
        _FILEDATE,
        _FILENAME
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(ENTITYNAME as VARCHAR(16777216)) as ENTITYNAME,
        CAST(OPTIONSETNAME as VARCHAR(16777216)) as OPTIONSETNAME,
        CAST(OPTION as NUMBER(38,0)) as OPTION,
        CAST(ISUSERLOCALIZEDLABEL as BOOLEAN) as ISUSERLOCALIZEDLABEL,
        CAST(LOCALIZEDLABELLANGUAGECODE as NUMBER(38,0)) as LOCALIZEDLABELLANGUAGECODE,
        CAST(LOCALIZEDLABEL as VARCHAR(16777216)) as LOCALIZEDLABEL,
        CAST(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        CAST(_FILENAME as VARCHAR(16777216)) as _FILENAME
from transform_data
)

select * from type_data