{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='FILE_COST_CENTER',
    unique_key= ['COST_CENTER_CODE']
) }}

with source_data as 
(
    SELECT 
    COST_CENTER_CODE,
    COST_CENTER_NAME,
    substring(COST_CENTER_CODE,4,2) as SEGMENT_CODE,
    SEGMENT,
    substring(COST_CENTER_CODE,6,3) AS DEPARTMENT_CODE,
    DEPARTMENT,
    substring(COST_CENTER_CODE,9,2) AS OFFICE_CODE,
    OFFICE,
    _FILEDATE
    FROM {{ source("FILE", "COST_CENTER") }}
        {% if is_tel_incremental() %}WHERE  _FileDate > IFNULL((SELECT MAX(_FileDate) FROM {{ this }}),'1970-01-01'){% endif %}
		QUALIFY (ROW_NUMBER() OVER (PARTITION BY COST_CENTER_CODE ORDER BY _Filedate DESC )) = 1
)


,transform_data as 
(
    SELECT 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        COST_CENTER_CODE,
        COST_CENTER_NAME,
        SEGMENT_CODE,
        SEGMENT,
        DEPARTMENT_CODE,
        DEPARTMENT,
        OFFICE_CODE,
        OFFICE,
        _FILEDATE
    FROM source_data 
)
,type_data as 
(
    select
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        COST_CENTER_CODE,
        COST_CENTER_NAME,
        SEGMENT_CODE,
        SEGMENT,
        DEPARTMENT_CODE,
        DEPARTMENT,
        OFFICE_CODE,
        OFFICE,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE
    from transform_data
    )
select * from type_data