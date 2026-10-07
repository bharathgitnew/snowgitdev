{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SAP_SALES_CATEGORY',
    tags=["finance"]
) }}

with source_data as
(
    SELECT
		_FILENAME,
		_FILEDATE,
		_UPLOADDATE,
        BAAN_PRODUCT_TYPE,
        BAAN_PRODUCT_TYPE_NAME,
        SAP_SALES_CATEGORY,
        SAP_SALES_CATEGORY_NAME
    FROM {{ ref('BRONZE__TEH_FINANCE__FILE_SAP_SALES_CATEGORY') }}
  
  
 
)

,transform_data as
(
    SELECT
		_FILENAME,
		_FILEDATE,
		_UPLOADDATE,
        BAAN_PRODUCT_TYPE,
        BAAN_PRODUCT_TYPE_NAME,
        SAP_SALES_CATEGORY,
        SAP_SALES_CATEGORY_NAME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
        FROM source_data
)

,type_data as
(
    select
        CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        CAST(BAAN_PRODUCT_TYPE AS VARCHAR(16777216)) AS BAAN_PRODUCT_TYPE,
        CAST(BAAN_PRODUCT_TYPE_NAME AS VARCHAR(16777216)) AS BAAN_PRODUCT_TYPE_NAME,
        CAST(SAP_SALES_CATEGORY AS VARCHAR(16777216)) AS SAP_SALES_CATEGORY,
        CAST(SAP_SALES_CATEGORY_NAME AS VARCHAR(16777216)) AS SAP_SALES_CATEGORY_NAME,
        CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
    from transform_data
    )
select * from type_data

