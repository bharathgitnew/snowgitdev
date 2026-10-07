{{ config(
    alias='SAPO_DOCUMENT_EXPORT_CONTROL_DATA_AT_ITEM_LEVEL',
    incremental_strategy='merge',
    unique_key = [
        'VBELN',
        'POSNR',
        'GEGRU'
    ],
) }}

with source_data as (
	select 
        _CAPTUREDATETIME,
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
        STATU,
	from {{ source('SAP_ORACLE_LIVE', 'ZVBEX') }}
),


transform_data as (
    select
        '{{ invocation_id }}' as _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        *,
	from source_data
), 

type_data as (
    select 
        _CAPTUREDATETIME::timestamp_ltz(9) as _CAPTUREDATETIME,
        _AUDIT_LOG_ID::varchar(128) as _AUDIT_LOG_ID,
        _ROW_HASH::varchar(128) as _ROW_HASH,
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
        STATU,
    from transform_data
)
 
select * from type_data