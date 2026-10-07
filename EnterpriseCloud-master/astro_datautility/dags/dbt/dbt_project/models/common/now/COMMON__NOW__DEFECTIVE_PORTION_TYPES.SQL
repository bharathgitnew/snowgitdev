{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='Defective_portion_types'
) }}


with source_data as 
(
    SELECT 
        DEFECTIVE_PORTION_ID AS DEFECTIVE_PORTION_ID
        , DESCRIPTION AS DESCRIPTION
        , SORT_ORDER AS SORT_ORDER
        , _FILEDATE
        , _FILENAME
        FROM {{ ref('ODS__NOW__DEFECTIVE_PORTION_TYPES') }}  
)

,transform_data as
(
    SELECT 
        DEFECTIVE_PORTION_ID, 
        DESCRIPTION, 
        SORT_ORDER ,
        _FILEDATE,
        _FILENAME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
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
        CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
    from transform_data
)
select * from type_data