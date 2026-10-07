{{ config(
    alias = 'SAPO_CONDITIONS_FOR_CUSTOMER_MATERIAL',
    materialized = 'tel_incremental',
    incremental_strategy = 'insert_overwrite',
    unique_key = ['MANDT', 'KAPPL', 'KSCHL', 'VKORG', 'VTWEG', 'KUNNR', 'MATNR', 'DATBI'],
) }}

with source_data as (
	select 
        *,
	from {{ source('SAP_ORACLE_LIVE', 'A005') }}
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
        _AUDIT_LOG_ID::varchar(128) as _AUDIT_LOG_ID,
        _ROW_HASH::varchar(128) as _ROW_HASH,
        _CAPTUREDATETIME::timestamp_ltz(9) as _CAPTUREDATETIME,
        MANDT,
        KAPPL,
        KSCHL,
        VKORG,
        VTWEG,
        KUNNR,
        MATNR,
        DATBI,
        DATAB,
        KNUMH
    from transform_data
)
 
select * from type_data