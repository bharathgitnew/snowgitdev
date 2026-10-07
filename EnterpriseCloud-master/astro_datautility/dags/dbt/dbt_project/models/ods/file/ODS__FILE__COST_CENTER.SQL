{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='COST_CENTER',
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
        {% if is_incremental() %}WHERE  _FileDate > IFNULL((SELECT MAX(_FileDate) FROM {{ this }}),'1970-01-01'){% endif %}
		QUALIFY (ROW_NUMBER() OVER (PARTITION BY COST_CENTER_CODE ORDER BY _Filedate DESC )) = 1
)


,transform_data as 
(
    SELECT 
        COST_CENTER_CODE,
        COST_CENTER_NAME,
        SEGMENT_CODE,
        SEGMENT,
        DEPARTMENT_CODE,
        DEPARTMENT,
        OFFICE_CODE,
        OFFICE,
        _FILEDATE,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
    FROM source_data 
)
,type_data as 
(
    select
        cast(COST_CENTER_CODE as VARCHAR(16777216)) as COST_CENTER_CODE,
        cast(COST_CENTER_NAME as VARCHAR(16777216)) as COST_CENTER_NAME,
        cast(SEGMENT_CODE as VARCHAR(16777216)) as SEGMENT_CODE,
        cast(SEGMENT as VARCHAR(16777216)) as SEGMENT,
        cast(DEPARTMENT_CODE as VARCHAR(16777216)) as DEPARTMENT_CODE,
        cast(DEPARTMENT as VARCHAR(16777216)) as DEPARTMENT,
        cast(OFFICE_CODE as VARCHAR(16777216)) as OFFICE_CODE,
        cast(OFFICE as VARCHAR(16777216)) as OFFICE,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data