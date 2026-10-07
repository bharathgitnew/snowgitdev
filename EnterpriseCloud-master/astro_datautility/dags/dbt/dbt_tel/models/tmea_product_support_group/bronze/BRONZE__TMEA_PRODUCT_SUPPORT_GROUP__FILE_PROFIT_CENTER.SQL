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
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        _FILEDATE,
        PROFIT_CENTER_CODE,
        PROFIT_CENTER_NAME,
        SEGMENT_CODE,
        SEGMENT,
        DEPARTMENT_CODE,
        DEPARTMENT,
        OFFICE_CODE,
        OFFICE,
        NOTES
    FROM source_data 
)

,type_data as (
    SELECT
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(PROFIT_CENTER_CODE AS VARCHAR(16777216)) AS PROFIT_CENTER_CODE,
        CAST(PROFIT_CENTER_NAME AS VARCHAR(16777216)) AS PROFIT_CENTER_NAME,
        cast(SEGMENT_CODE as VARCHAR(16777216)) as SEGMENT_CODE,
        CAST(SEGMENT AS VARCHAR(16777216)) AS SEGMENT,
        cast(DEPARTMENT_CODE as VARCHAR(16777216)) as DEPARTMENT_CODE,
        CAST(DEPARTMENT AS VARCHAR(16777216)) AS DEPARTMENT,
        cast(OFFICE_CODE as VARCHAR(16777216)) as OFFICE_CODE,
        CAST(OFFICE AS VARCHAR(16777216)) AS OFFICE,
        CAST(NOTES AS VARCHAR(16777216)) AS NOTES
    FROM transform_data
)

SELECT * from type_data