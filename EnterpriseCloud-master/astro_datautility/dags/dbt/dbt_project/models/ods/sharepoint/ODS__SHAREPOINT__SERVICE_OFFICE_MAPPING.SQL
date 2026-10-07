{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='SERVICE_OFFICE_MAPPING'
) }}


with source_data as
(
    SELECT
	    _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
	    jsonfield:fields.field_0::STRING as OFFICE_CODE,
        jsonfield:fields.Title::STRING as OFFICE,
        jsonfield:fields.field_2::STRING as REGION,
        jsonfield:fields.field_3::STRING as REGION_GROUP,
        jsonfield:fields.field_4::STRING as REGION_GROUP2
        from {{ source("SHAREPOINT", "SERVICE_OFFICE_MAPPING") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) from {{ source("SHAREPOINT", "SERVICE_OFFICE_MAPPING") }})
    )
,transform_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
	    OFFICE_CODE,
	    OFFICE,
	    REGION,
	    REGION_GROUP,
	    REGION_GROUP2
        FROM source_data
        )
,type_data as
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        _FILEDATE,
	    OFFICE_CODE,
	    OFFICE,
	    REGION,
	    REGION_GROUP,
	    REGION_GROUP2
    from transform_data
    )
select * from type_data