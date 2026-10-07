{{ config(
      materialized='tel_incremental',
      incremental_strategy='insert_overwrite',
      alias='SHAREPOINT_TMEA_ENVIRONMENTAL_KPI',
      transient=false
) }} 

with source_data as (
	SELECT
    _FILEDATE,
    jsonfield:fields.id::string as ID, 
    jsonfield:fields.Attachments::string as ATTACHMENTS,
    jsonfield:fields.FiscalYear::string as FISCALYEAR,
    jsonfield:fields.KPI::string as KPI,    
    jsonfield:fields.Month::string as MONTH,
    jsonfield:fields.Target::string as TARGET,
    jsonfield:fields.Title::string as TITLE,
    jsonfield:fields.Value::string as VALUE,
    jsonfield:fields.LinkTitle::string as LINKTITLE,
    jsonfield:fields.LinkTitleNoMenu::string as LINKTITLENOMENU
	from {{ source('SHAREPOINT','TMEA_ENVIRONMENTAL_KPI') }}
	where _FILEDATE = (SELECT MAX(_FILEDATE) from {{ source('SHAREPOINT','TMEA_ENVIRONMENTAL_KPI') }})
),

transform_data as (
	SELECT
    _FILEDATE,
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.
	ID,
    ATTACHMENTS,
    FISCALYEAR,
    KPI,
    MONTH,
    TARGET,
    TITLE,
    VALUE,
    LINKTITLE,
    LINKTITLENOMENU
    from source_data
),

type_data as (
	SELECT 
        cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        ID,
        ATTACHMENTS,
        FISCALYEAR,
        KPI,
        MONTH,
        TARGET,
        TITLE,
        VALUE,
        LINKTITLE,
        LINKTITLENOMENU
	from transform_data
)

select * from type_data