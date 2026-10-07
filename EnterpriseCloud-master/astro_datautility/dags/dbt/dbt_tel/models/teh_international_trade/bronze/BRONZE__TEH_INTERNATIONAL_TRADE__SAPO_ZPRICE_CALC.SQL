{{ config(
    alias = 'SAPO_ZPRICE_CALC',
    materialized = 'tel_incremental',
    incremental_strategy = 'insert_overwrite',
) }}

with source_data as (
    select
        *
    from {{ source('SAP_ORACLE_LIVE', 'ZPRICE_CALC') }} 
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        current_timestamp()::timestamp_ntz as _REFRESHDATE,
        *,
    from source_data
),

type_data as (
    select 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        _CAPTUREDATETIME,
        _REFRESHDATE,
        MANDT,
        SALES_CODE,
        DIVISION,
        START_DATE,
        STD_COST_LOW,
        STD_COST_HIGH,
        CURRENCY,
        SALE_PRC_MULT,
        TRAN_PRC_PERCENT,
    from transform_data
)

select * from type_data
