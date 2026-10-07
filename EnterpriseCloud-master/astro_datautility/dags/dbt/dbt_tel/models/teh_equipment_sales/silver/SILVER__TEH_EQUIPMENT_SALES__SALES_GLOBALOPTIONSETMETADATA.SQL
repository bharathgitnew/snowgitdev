{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='sales_globaloptionsetmetadata',
    	transient=false
) }}

with source_data as (
    SELECT
    OPTIONSETNAME,
 	OPTION,
 	ISUSERLOCALIZEDLABEL,
 	LOCALIZEDLABELLANGUAGECODE,
 	LOCALIZEDLABEL
    FROM {{ ref('BRONZE__TEH_EQUIPMENT_SALES__CRM_FILE_GLOBALOPTIONSETMETADATA') }}
),

transform_data as (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        OPTIONSETNAME,
        OPTION,
        ISUSERLOCALIZEDLABEL,
        LOCALIZEDLABELLANGUAGECODE,
        LOCALIZEDLABEL
from source_data
),

type_data as (
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(OPTIONSETNAME AS VARCHAR(16777216)) AS OPTIONSETNAME,
        CAST(OPTION AS NUMBER(38,0)) AS OPTION,
        CAST(ISUSERLOCALIZEDLABEL AS BOOLEAN) AS ISUSERLOCALIZEDLABEL,
        CAST(LOCALIZEDLABELLANGUAGECODE AS NUMBER(38,0)) AS LOCALIZEDLABELLANGUAGECODE,
        CAST(LOCALIZEDLABEL AS VARCHAR(16777216)) AS LOCALIZEDLABEL
from transform_data
)

select * from type_data