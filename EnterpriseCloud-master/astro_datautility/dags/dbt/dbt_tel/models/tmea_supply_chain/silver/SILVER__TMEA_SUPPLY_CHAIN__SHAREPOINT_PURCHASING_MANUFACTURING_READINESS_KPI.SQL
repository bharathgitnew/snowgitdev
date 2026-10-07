{{ config(
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        alias='SHAREPOINT_PURCHASING_MANUFACTURING_READINESS_KPI',
        unique_key = [],
        transient=false
) }}
with source_data as (
 SELECT
        _FILENAME,
        _FILEDATE,
        FIELDS_TITLE  AS SALES_ORDER,
        FIELDS_FIELD_1 AS PRODUCT_CODE,
        FIELDS_FIELD_2 AS SYSTEM_TYPE,
        TO_DATE(FIELDS_FIELD_3) AS MMR_DATE,
        TO_DATE(FIELDS_FIELD_4) AS SOC_DATE,
        FIELDS_FIELD_7 AS CONFIG,
        FIELDS_FIELD_9 AS ECN,
        FIELDS_FIELD_10 AS ECN_NUMBER,
        FIELDS_RFQ_X002F_CSD AS RFQ_CSD,
        FIELDS_QDA AS QDA,
        TO_DATE(LASTMODIFIEDDATETIME)  AS MODIFIED,
        TO_DATE(CREATEDDATETIME)  AS CREATED,
        CREATEDBY_USER_DISPLAYNAME AS CREATED_BY,
        LASTMODIFIEDBY_USER_DISPLAYNAME AS MODIFIED_BY
FROM {{ ref('BRONZE__TMEA_SUPPLY_CHAIN__SHAREPOINT_PURCHASING_MANUFACTURING_READINESS_KPI') }}
),
transform_data as(
        SELECT 
         '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
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
FROM source_data
),
type_data as (
        SELECT 
        _AUDIT_LOG_ID,
        _ROW_HASH,
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
FROM transform_data
)
SELECT * FROM type_data
