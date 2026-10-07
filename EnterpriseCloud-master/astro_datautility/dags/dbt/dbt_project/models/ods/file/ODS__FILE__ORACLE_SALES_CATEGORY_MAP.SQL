{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='ORACLE_SALES_CATEGORY_MAP'
) }}

with source_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        SAP_CODE,
        ORACLE_CODE
    FROM {{ source("FILE", "ORACLE_SALES_CATEGORY_MAP") }}

    where _UPLOADDATE = (select max(_UPLOADDATE) from {{ source("FILE", "ORACLE_SALES_CATEGORY_MAP") }})

)

,transform_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        SAP_CODE,
        ORACLE_CODE,
        '{{ invocation_id }}' AS AUDIT_LOG_ID
        FROM source_data
)

,type_data as
(
    select
        CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        CAST(SAP_CODE AS VARCHAR(16777216)) AS SAP_CODE,
        CAST(ORACLE_CODE AS VARCHAR(16777216)) AS ORACLE_CODE,
        CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID
    from transform_data
    )
select * from type_data