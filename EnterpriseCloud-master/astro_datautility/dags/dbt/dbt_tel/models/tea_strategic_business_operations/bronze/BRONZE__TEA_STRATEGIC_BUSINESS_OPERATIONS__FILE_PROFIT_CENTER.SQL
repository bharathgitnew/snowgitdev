{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='FILE_PROFIT_CENTER',
    unique_key= ['PROFIT_CENTER_CODE']
) }}

with source_data as
(
    SELECT
    PROFIT_CENTER_CODE,
    PROFIT_CENTER_NAME,
    substring(PROFIT_CENTER_CODE,4,2) as SEGMENT_CODE,
    SEGMENT,
    substring(PROFIT_CENTER_CODE,6,3) AS DEPARTMENT_CODE,
    DEPARTMENT,
    substring(PROFIT_CENTER_CODE,9,2) AS OFFICE_CODE,
    OFFICE,
    NOTES,
    _FILEDATE
    FROM {{ source("FILE", "PROFIT_CENTER") }}
        {% if is_tel_incremental() %}WHERE  _FileDate > IFNULL((SELECT MAX(_FileDate) FROM {{ this }}),'1970-01-01'){% endif %}
		QUALIFY (ROW_NUMBER() OVER (PARTITION BY PROFIT_CENTER_CODE ORDER BY _Filedate DESC )) = 1
)


,transform_data as 
(
    SELECT 
        PROFIT_CENTER_CODE,
        PROFIT_CENTER_NAME,
        SEGMENT_CODE,
        SEGMENT,
        DEPARTMENT_CODE,
        DEPARTMENT,
        OFFICE_CODE,
        OFFICE,
        NOTES,
        _FILEDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
    FROM source_data 
)

,type_data as (
    SELECT
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        _AUDIT_LOG_ID AS _AUDIT_LOG_ID,
        _ROW_HASH AS _ROW_HASH,
        PROFIT_CENTER_CODE AS PROFIT_CENTER_CODE,
        PROFIT_CENTER_NAME AS PROFIT_CENTER_NAME,
        SEGMENT_CODE as SEGMENT_CODE,
        SEGMENT AS SEGMENT,
        DEPARTMENT_CODE as DEPARTMENT_CODE,
        DEPARTMENT AS DEPARTMENT,
        OFFICE_CODE as OFFICE_CODE,
        OFFICE AS OFFICE,
        NOTES AS NOTES
    FROM transform_data
)

SELECT * from type_data