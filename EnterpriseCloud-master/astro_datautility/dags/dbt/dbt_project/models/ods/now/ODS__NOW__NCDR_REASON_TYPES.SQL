{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='NCDR_REASON_TYPES'
) }}


with source_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        JSONFIELD:REASON_ID::STRING AS REASON_ID,
        JSONFIELD:DESCRIPTION::STRING AS DESCRIPTION,
        JSONFIELD:SORT_ORDER::STRING AS SORT_ORDER,
        JSONFIELD:ORDER_REASON::STRING AS ORDER_REASON,
        JSONFIELD:NO_MACHINE_FLG::STRING AS NO_MACHINE_FLG
        FROM {{ source("NOW", "NCDR_REASON_TYPES") }}
        WHERE _FILEDATE = (
            SELECT MAX(RUN_TIME)
            FROM {{ source('NOW', 'CONTROLTABLE') }}
            WHERE TABLE_NAME = 'T_NCDR_REASON_TYPES'
            ) 
        )
,transform_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        REASON_ID,
        DESCRIPTION,
        SORT_ORDER,
        ORDER_REASON,
        NO_MACHINE_FLG
    FROM source_data
),

type_data as (
select
    CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
    CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
    CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
    CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
    REASON_ID,
    DESCRIPTION,
    SORT_ORDER,
    ORDER_REASON,
    NO_MACHINE_FLG
from transform_data
)

select * from type_data