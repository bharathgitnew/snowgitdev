{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SHAREPOINT_MACHINE_MODEL_MAPPING'
) }}


with source_data as
(
    SELECT
	    _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
	    jsonfield:fields.Title::STRING as MACHINE_MODEL_KEY,
        jsonfield:fields.field_1::STRING as MODEL_GROUP1,
        jsonfield:fields.field_2::STRING as MODEL_GROUP2,
        jsonfield:fields.field_3::STRING as MODEL_GROUP3,
        jsonfield:fields.field_4::STRING as PLANNING_INSTALL_DURATION_MONTH,
        jsonfield:fields.field_5::STRING as PLANNING_INSTALL_DURATION_HOUR,
        jsonfield:fields.field_6::STRING as PLANNING_WARRANTY_FACTOR,
        jsonfield:fields.field_7::STRING as PLANNING_WARRANTY_HOUR,
        jsonfield:fields.field_8::STRING as USED_FLAG
        from {{ source("SHAREPOINT", "MACHINE_MODEL_MAPPING") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) from {{ source("SHAREPOINT", "MACHINE_MODEL_MAPPING") }})

    )
,transform_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
	    MACHINE_MODEL_KEY,
	    MODEL_GROUP1,
	    MODEL_GROUP2,
	    MODEL_GROUP3,
	    PLANNING_INSTALL_DURATION_MONTH,
	    PLANNING_INSTALL_DURATION_HOUR,
	    PLANNING_WARRANTY_FACTOR,
	    PLANNING_WARRANTY_HOUR,
        USED_FLAG
        FROM source_data
        )
,type_data as
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
	    MACHINE_MODEL_KEY,
	    MODEL_GROUP1,
	    MODEL_GROUP2,
	    MODEL_GROUP3,
	    PLANNING_INSTALL_DURATION_MONTH,
	    PLANNING_INSTALL_DURATION_HOUR,
	    PLANNING_WARRANTY_FACTOR,
	    PLANNING_WARRANTY_HOUR,
        USED_FLAG
    from transform_data
    )
select * from type_data