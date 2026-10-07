{{ config(
            materialized='incremental',
            incremental_strategy='insert_overwrite',
            alias='SAP_DELIVERY_DOC_TYPE',
            transient=false    
) }}

WITH 
SOURCE_DATA AS (
    SELECT
        LFART AS DELIVERY_DOC_TYPE,
        VTEXT AS DELIVERY_DOC_TYPE_DESC
    FROM {{ ref('ODS__SAPAPI__ZCDV_T_CMTU200_TVLKT') }} AS TVLKT
    -- where language is english
    WHERE SPRAS = 'EN'
),
TRANSFORM_DATA AS (
    SELECT 
        DELIVERY_DOC_TYPE, 
        DELIVERY_DOC_TYPE_DESC,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
    FROM SOURCE_DATA
),
TYPE_DATA AS (
    SELECT 
        CAST(DELIVERY_DOC_TYPE AS VARCHAR(16777216)) AS DELIVERY_DOC_TYPE,
        CAST(DELIVERY_DOC_TYPE_DESC AS VARCHAR(16777216)) AS DELIVERY_DOC_TYPE_DESC,
        CAST(AUDIT_LOG_ID AS VARCHAR(16777216)) AS AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(16777216)) AS _ROW_HASH
    FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA