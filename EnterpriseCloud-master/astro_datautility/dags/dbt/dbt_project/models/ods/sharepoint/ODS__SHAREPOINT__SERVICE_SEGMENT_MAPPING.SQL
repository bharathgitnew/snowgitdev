{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='SERVICE_SEGMENT_MAPPING'
) }}


with source_data as
(
    SELECT
	    _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
	    jsonfield:fields.field_0::STRING as SEGMENT_CODE,
        jsonfield:fields.Title::STRING as SEGMENT_NAME,
        jsonfield:fields.field_2::STRING as SOURCE,
        jsonfield:fields.field_3::STRING as BU_GROUP,
        jsonfield:fields.field_4::STRING as BU_GROUP_2,
        jsonfield:fields.field_5::STRING as MACHINE_BU,
        jsonfield:fields.field_6::STRING as GCE_BU,
        jsonfield:fields.field_7::STRING as FS_FLAG,
        from {{ source("SHAREPOINT", "SERVICE_SEGMENT_MAPPING") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) from {{ source("SHAREPOINT", "SERVICE_SEGMENT_MAPPING") }})

    )
,transform_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
	    SEGMENT_CODE,
	    SEGMENT_NAME,
	    SOURCE,
	    BU_GROUP,
	    BU_GROUP_2,
	    MACHINE_BU,
	    GCE_BU,
	    FS_FLAG
        FROM source_data
        )
,type_data as
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        _FILEDATE,
	    SEGMENT_CODE,
	    SEGMENT_NAME,
	    SOURCE,
	    BU_GROUP,
	    BU_GROUP_2,
	    MACHINE_BU,
	    GCE_BU,
	    FS_FLAG
    from transform_data
    )
select * from type_data