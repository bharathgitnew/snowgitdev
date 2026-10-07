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
    FROM {{ ref('BRONZE__TEH_SALES_TO_INSTALLATION__CRM_FILE_GLOBALOPTIONSETMETADATA') }}
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
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        OPTIONSETNAME,
 	 	CAST(OPTION AS NUMBER(38,0)) AS OPTION,
 	 	ISUSERLOCALIZEDLABEL,
 	 	CAST(LOCALIZEDLABELLANGUAGECODE AS NUMBER(38,0)) AS LOCALIZEDLABELLANGUAGECODE,
 	 	LOCALIZEDLABEL
    from transform_data
)

select * from type_data