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
        REASON_ID,
        DESCRIPTION,
        SORT_ORDER,
        ORDER_REASON,
        NO_MACHINE_FLG
        FROM {{ ref('ODS__NOW__NCDR_REASON_TYPES') }}
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