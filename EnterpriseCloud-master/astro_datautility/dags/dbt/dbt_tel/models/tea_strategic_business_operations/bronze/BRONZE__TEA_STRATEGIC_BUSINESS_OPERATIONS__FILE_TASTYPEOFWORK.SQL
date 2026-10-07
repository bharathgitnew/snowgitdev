{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='FILE_TASTYPEOFWORK',
) }}


with source_data as
(
    SELECT
        _FILEDATE,
        _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        _UPLOADDATE,
        TYPE_OF_WORK,
        TAS_TYPE_OF_WORK,
        TAS_TYPE_OF_WORK_GROUP,
        SOURCE,
        SERVICE_UTILIZATION_GROUP,
        REVENUE_SOURCE,
        LEGACY_TYPE_OF_WORK,
        BILLABLE_CATEGORY_GROUP,
        EXPECTED_SO_SERIES,
        SO_EXPECTED_IN_CRM,
        SERVICE_COSTING_PRODUCT_TYPE_CODE
    FROM {{ source("FILE", "TASTYPEOFWORK") }}
    WHERE _FileDate = (SELECT MAX(_FileDate) FROM {{ source("FILE", "TASTYPEOFWORK") }})
),

transform_data as(
    SELECT
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        BILLABLE_CATEGORY_GROUP,
        EXPECTED_SO_SERIES,
        LEGACY_TYPE_OF_WORK,
        REVENUE_SOURCE,
        SO_EXPECTED_IN_CRM,
        SERVICE_COSTING_PRODUCT_TYPE_CODE,
        SERVICE_UTILIZATION_GROUP,
        SOURCE,
        TAS_TYPE_OF_WORK,
        TAS_TYPE_OF_WORK_GROUP,
        TYPE_OF_WORK
    FROM source_data
),

type_data as(
    select
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        _FILENAME AS _FILENAME,
        _AUDIT_LOG_ID AS _AUDIT_LOG_ID,
        _ROW_HASH AS _ROW_HASH,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        TYPE_OF_WORK as TYPE_OF_WORK,
        TAS_TYPE_OF_WORK as TAS_TYPE_OF_WORK,
        TAS_TYPE_OF_WORK_GROUP as TAS_TYPE_OF_WORK_GROUP,
        SOURCE as SOURCE,
        SERVICE_UTILIZATION_GROUP as SERVICE_UTILIZATION_GROUP,
        SO_EXPECTED_IN_CRM as SO_EXPECTED_IN_CRM,
        REVENUE_SOURCE as REVENUE_SOURCE,
        EXPECTED_SO_SERIES as EXPECTED_SO_SERIES,
        LEGACY_TYPE_OF_WORK as LEGACY_TYPE_OF_WORK,
        SERVICE_COSTING_PRODUCT_TYPE_CODE as SERVICE_COSTING_PRODUCT_TYPE_CODE,
        BILLABLE_CATEGORY_GROUP as BILLABLE_CATEGORY_GROUP
    from transform_data
)

select * from type_data