{{ config(
            materialized='incremental',
            incremental_strategy='insert_overwrite',
            alias='SAP_SALES_DOC_TYPE',
            transient=false    
) }}

WITH 
SOURCE_DATA AS (
    SELECT
        AUART AS SALES_DOC_TYPE,
        BEZEI AS SALES_DOC_TYPE_DESC
    FROM {{ ref('ODS__SAPAPI__ZCDV_T_CMTU023_TVAKT') }} AS TVAKT
    -- where language is english
    WHERE SPRAS = 'EN'
),
TRANSFORM_DATA AS (
    SELECT SALES_DOC_TYPE, SALES_DOC_TYPE_DESC FROM SOURCE_DATA
),
TYPE_DATA AS (
    SELECT 
        CAST(SALES_DOC_TYPE AS VARCHAR(16777216)) AS SALES_DOC_TYPE,
        CAST(SALES_DOC_TYPE_DESC AS VARCHAR(16777216)) AS SALES_DOC_TYPE_DESC
    FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA