{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SHAREPOINT_SERVICE_PRODUCT_TYPE_MAPPING'
) }}


with source_data as
(
    SELECT
	    _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
	    jsonfield:fields.Title::STRING as PT_KEY,
        jsonfield:fields.field_1::STRING as PRODUCT_TYPE,
        jsonfield:fields.field_2::STRING as PRODUCT_TYPE_MAPPED,
        jsonfield:fields.field_3::STRING as PRODUCT_TYPE_CATEGORY,
        jsonfield:fields.field_4::STRING as PRODUCT_TYPE_GROUP,
        jsonfield:fields.field_5::STRING as PRODUCT_TYPE_GROUP2,
        jsonfield:fields.field_6::STRING as REVENUE_SOURCE,
        jsonfield:fields.field_7::STRING as STATUTORY_GROUP,
        jsonfield:fields.field_8::STRING as PRODUCT_TYPE_CODE_MAPPED
        from {{ source("SHAREPOINT", "SERVICE_PRODUCT_TYPE_MAPPING") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) from {{ source("SHAREPOINT", "SERVICE_PRODUCT_TYPE_MAPPING") }})

    )
,transform_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
	    PT_KEY,
	    PRODUCT_TYPE,
	    PRODUCT_TYPE_MAPPED,
	    PRODUCT_TYPE_CATEGORY,
	    PRODUCT_TYPE_GROUP,
	    PRODUCT_TYPE_GROUP2,
	    REVENUE_SOURCE,
	    STATUTORY_GROUP,
        PRODUCT_TYPE_CODE_MAPPED
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
	    PT_KEY,
	    PRODUCT_TYPE,
	    PRODUCT_TYPE_MAPPED,
	    PRODUCT_TYPE_CATEGORY,
	    PRODUCT_TYPE_GROUP,
	    PRODUCT_TYPE_GROUP2,
	    REVENUE_SOURCE,
	    STATUTORY_GROUP,
        PRODUCT_TYPE_CODE_MAPPED
    from transform_data
    )
select * from type_data