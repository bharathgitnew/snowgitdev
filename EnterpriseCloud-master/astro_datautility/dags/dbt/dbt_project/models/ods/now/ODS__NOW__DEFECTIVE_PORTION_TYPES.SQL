{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='DEFECTIVE_PORTION_TYPES'
) }}


with source_data as 
(
    SELECT 
        JSONFIELD:DEFECTIVE_PORTION_ID::STRING AS DEFECTIVE_PORTION_ID
        , JSONFIELD:DESCRIPTION::STRING AS DESCRIPTION
        , JSONFIELD:SORT_ORDER::STRING AS SORT_ORDER
        , _FILEDATE
        , _FILENAME
        FROM {{ source("NOW", "DEFECTIVE_PORTION_TYPES") }}  
        WHERE _FILEDATE = (
            SELECT MAX(RUN_TIME)
            FROM {{ source('NOW', 'CONTROLTABLE') }}
            WHERE TABLE_NAME = 'T_DEFECTIVE_PORTION_TYPES'
            ) 
        )
,transform_data as
(
    SELECT 
        DEFECTIVE_PORTION_ID, 
        DESCRIPTION, 
        SORT_ORDER,
        _FILEDATE,
         _FILENAME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID
        FROM source_data
)
,type_data as 
(
    select
        cast(DEFECTIVE_PORTION_ID as VARCHAR(16777216)) as DEFECTIVE_PORTION_ID,
        cast(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION,
        cast(SORT_ORDER as VARCHAR(16777216)) as SORT_ORDER,
        CAST(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
		CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
        cast(AUDIT_LOG_ID as VARCHAR(16777216)) as AUDIT_LOG_ID
    from transform_data
)
select * from type_data