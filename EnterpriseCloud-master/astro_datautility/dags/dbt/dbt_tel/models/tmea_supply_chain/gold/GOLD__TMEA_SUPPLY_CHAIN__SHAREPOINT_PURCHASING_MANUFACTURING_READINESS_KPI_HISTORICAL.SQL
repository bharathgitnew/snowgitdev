{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='SHAREPOINT_PURCHASING_MANUFACTURING_READINESS_KPI_HISTORICAL',
        unique_key = ['REPORT_DATE'],
        transient=false
) }}

WITH source_data AS (
    SELECT * exclude (_AUDIT_LOG_ID, _ROW_HASH )
    FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__SHAREPOINT_PURCHASING_MANUFACTURING_READINESS_KPI') }} 
    ),
transform_data AS (
    SELECT 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
	    SHA2('hash_me') as _ROW_HASH,
        current_timestamp() as REPORT_DATE,
        *
    from source_data
    ),
type_data AS (
    SELECT 
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(REPORT_DATE as TIMESTAMP_LTZ(9)) as REPORT_DATE,
        _FILENAME,
        _FILEDATE,
        SALES_ORDER,
        PRODUCT_CODE,
        SYSTEM_TYPE,
        MMR_DATE,
        SOC_DATE,
        CONFIG,
        ECN,
        ECN_NUMBER,
        RFQ_CSD,
        QDA,
        MODIFIED,
        CREATED,
        CREATED_BY,
        MODIFIED_BY
     from transform_data
    )

SELECT *
FROM type_data
