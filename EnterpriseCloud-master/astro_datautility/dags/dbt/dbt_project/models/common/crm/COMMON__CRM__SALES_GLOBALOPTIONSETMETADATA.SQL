{{ config(
    	materialized='incremental',
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
    FROM {{ ref('ODS__CRM_FILE__GLOBALOPTIONSETMETADATA') }}
),

transform_data as (
    SELECT
    OPTIONSETNAME,
 	OPTION,
 	ISUSERLOCALIZEDLABEL,
 	LOCALIZEDLABELLANGUAGECODE,
 	LOCALIZEDLABEL,
    '{{ invocation_id }}' AS AUDIT_LOG_ID
    from source_data
),

type_data as (
    select
        CAST(OPTIONSETNAME AS VARCHAR(16777216)) AS OPTIONSETNAME,
 	 	CAST(OPTION AS NUMBER(38,0)) AS OPTION,
 	 	CAST(ISUSERLOCALIZEDLABEL AS BOOLEAN) AS ISUSERLOCALIZEDLABEL,
 	 	CAST(LOCALIZEDLABELLANGUAGECODE AS NUMBER(38,0)) AS LOCALIZEDLABELLANGUAGECODE,
 	 	CAST(LOCALIZEDLABEL AS VARCHAR(16777216)) AS LOCALIZEDLABEL,
		CAST(AUDIT_LOG_ID AS varchar(128)) AS AUDIT_LOG_ID
    from transform_data
)

select * from type_data