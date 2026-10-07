{{ config(
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        alias='FILE_DEMAND_CAPACITY_LIST',
        transient=false
) }}

with source_data as 
(
    SELECT
    NO,
    IPN,
    SPN,
    DESCRIPTION
    FROM {{ source("FILE", "DEMAND_CAPACITY_LIST") }} vfbom
    --WHERE _Filedate = (SELECT MAX(_FileDate) from {{ source("FILE", "DEMAND_CAPACITY_LIST") }})
)

,transform_data as 
(
    SELECT
    NO,
    IPN,
    SPN,
    DESCRIPTION,
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
    FROM source_data
)

,type_data as 
(
    SELECT
    cast(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
    cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
    cast(NO as VARCHAR(16777216)) as NO,
    cast(IPN as VARCHAR(16777216)) as IPN,
    cast(SPN as VARCHAR(16777216)) as SPN,
    cast(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION
    FROM transform_data
)

SELECT * FROM type_data