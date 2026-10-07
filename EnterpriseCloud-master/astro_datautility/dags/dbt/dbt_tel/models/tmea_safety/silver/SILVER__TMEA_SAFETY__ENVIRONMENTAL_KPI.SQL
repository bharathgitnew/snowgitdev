{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='ENVIRONMENTAL_KPI',
    	  transient=false	
) }} 

with source_data as (
    SELECT
        _FILEDATE,
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
    from {{ ref('BRONZE__TMEA_SAFETY__SHAREPOINT_TMEA_ENVIRONMENTAL_KPI') }}
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
        _FILEDATE,
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