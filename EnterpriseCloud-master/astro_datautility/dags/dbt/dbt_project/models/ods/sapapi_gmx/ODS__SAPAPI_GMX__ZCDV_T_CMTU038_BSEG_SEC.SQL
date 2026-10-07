{{ config(
        materialized='incremental',
        incremental_strategy='insert_overwrite',
        alias='ZCDV_T_CMTU038_BSEG_SEC',
        transient=false
) }}

with source_data as (
    select
        _FILEDATE,
        _FILENAME,
        JSONFIELD:Bukrs::STRING AS BUKRS,
        JSONFIELD:Belnr::STRING AS BELNR,
        JSONFIELD:Gjahr::STRING AS GJAHR,
        JSONFIELD:Buzei::STRING AS BUZEI,
        JSONFIELD:Zlspr::STRING AS ZLSPR
    from {{ source('SAPAPI','ZCDV_T_CMTU038_BSEG_SEC') }}
    {% if is_incremental() %}WHERE  _FILEDATE > IFNULL((SELECT MAX(_FILEDATE) FROM {{ this }}),'1970-01-01'){% endif %}
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY BUKRS,BELNR,GJAHR,BUZEI ORDER BY _FILENAME DESC, _FILEDATE DESC )) = 1
),

transform_data as (
    select
        _FILEDATE,
        _FILENAME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.
        BUKRS,
        BELNR,
        GJAHR,
        BUZEI,
        ZLSPR
    from source_data
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        AUDIT_LOG_ID,
        _ROW_HASH,
        BUKRS,
        BELNR,
        GJAHR,
        BUZEI,
        ZLSPR
    from transform_data
)

select * from type_data