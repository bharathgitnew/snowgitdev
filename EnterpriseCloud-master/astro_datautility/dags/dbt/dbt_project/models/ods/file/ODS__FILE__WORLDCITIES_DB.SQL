{{ config(
        materialized='incremental',
        incremental_strategy='insert_overwrite',
        alias='WORLDCITIES_DB',
        unique_key= [],
        transient=false,
        enabled=true
) }}

WITH 
SOURCE_DATA AS (
    SELECT *
    FROM {{ source('FILE', 'WORLDCITIES_DB') }}
),
TRANSFORM_DATA AS (
    SELECT
        CITY,
        CITY_ASCII,
        LAT,
        LNG,
        COUNTRY,
        ISO2,
        ISO3,
        POP,
        ID,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
    FROM SOURCE_DATA
),
TYPE_DATA AS (
    SELECT
        CAST(CITY AS VARCHAR(16777216)) AS CITY,
        CAST(CITY_ASCII AS VARCHAR(16777216)) AS CITY_ASCII,
        CAST(LAT AS FLOAT) AS LAT,
        CAST(LNG AS FLOAT) AS LNG,
        CAST(COUNTRY AS VARCHAR(16777216)) AS COUNTRY,
        CAST(ISO2 AS VARCHAR(16777216)) AS ISO2,
        CAST(ISO3 AS VARCHAR(16777216)) AS ISO3,
        CAST(POP AS NUMBER(38,0)) AS POP,
        CAST(ID AS VARCHAR(16777216)) AS ID,
        CAST(AUDIT_LOG_ID AS VARCHAR(16777216)) AS AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(16777216)) AS _ROW_HASH
    FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA