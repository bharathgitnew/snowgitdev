{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='TPL_ASN_Supplier',
    unique_key = ['Supplier']
) }}


with source_data as (
    SELECT 
        SUPPLIER,
        ASN_ENABLED,
        _FILEDATE,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
    FROM {{ ref('ODS__THREEPL__TPL_ASN_SUPPLIER') }}
),

transform_data as(
    select
        SUPPLIER,
        ASN_ENABLED,
        _FILEDATE,
        AUDIT_LOG_ID,
        _ROW_HASH
    from source_data
),

type_data as(
    select
        CAST(SUPPLIER as VARCHAR(16777216)) as SUPPLIER,
        CAST(ASN_ENABLED as BOOLEAN) as ASN_ENABLED,
        CAST(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        CAST(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        CAST(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
)
select * from type_data