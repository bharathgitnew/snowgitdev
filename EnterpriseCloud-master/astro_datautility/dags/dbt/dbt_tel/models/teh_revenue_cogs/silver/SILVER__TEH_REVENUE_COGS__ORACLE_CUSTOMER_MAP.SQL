{{ config(
        materialized='tel_incremental',
     incremental_strategy = 'insert_overwrite',
     alias='ORACLE_CUSTOMER_MAP',
     tags=["finance"],
     transient=false
) }}

with source_data as (
    SELECT
        _FILENAME,
        _FILEDATE,
        SAP_CODE,
        ORACLE_CODE
    FROM {{ ref('BRONZE__TEH_REVENUE_COGS__SHAREPOINT_ORACLE_CUSTOMER') }}
)

, transform_data as (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        _FILENAME,
        _FILEDATE,
        SAP_CODE,
        ORACLE_CODE
    FROM source_data
)

, type_data as (
    select
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(SAP_CODE AS VARCHAR(16777216)) AS SAP_CODE,
        CAST(ORACLE_CODE AS VARCHAR(16777216)) AS ORACLE_CODE
    from transform_data
)

select * from type_data