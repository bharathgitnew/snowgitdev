{{ config(
        materialized='incremental',
        incremental_strategy='insert_overwrite',
        alias = 'SALES_DISTRIBUTION_DOCUMENT_EXPORT_CONTROL_ITEM_DATA',
        transient = false
) }}

with source_data as (
    select
        MANDT,
        VBELN,
        POSNR,
        GEGRU,
        ALNUM,
        EMBGR,
        GEART,
        GENNR,
        EXKUA,
        EXWAE,
        MODCO,
        AHBAS,
        SECGK,
        _DATAAGING,
        _CAPTUREDATETIME
    from {{source('SAP_ORACLE_LIVE', 'VBEX')}}
),

transform_data as (
    select
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
        MANDT AS MANDT,
        VBELN AS VBELN,
        POSNR AS POSNR,
        GEGRU AS GEGRU,
        ALNUM AS ALNUM,
        EMBGR AS EMBGR,
        GEART AS GEART,
        GENNR AS GENNR,
        EXKUA AS EXKUA,
        EXWAE AS EXWAE,
        MODCO AS MODCO,
        AHBAS AS AHBAS,
        SECGK AS SECGK,
        _DATAAGING AS _DATAAGING,
        _CAPTUREDATETIME AS _CAPTUREDATETIME
    from source_data
),

type_data as (
    select
		_AUDIT_LOG_ID,
		_ROW_HASH,
        MANDT,
        VBELN,
        CAST(POSNR as NUMBER(38,0)) as POSNR,
        GEGRU,
        ALNUM,
        EMBGR,
        GEART,
        GENNR,
        CAST(EXKUA as NUMBER(38,10)) as EXKUA,
        EXWAE,
        MODCO,
        AHBAS,
        SECGK,
        _DATAAGING,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME
    from transform_data
)
select * from type_data