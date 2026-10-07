{{ config(
        alias='SHAREPOINT_SAS_GOLDEN_SAMSUNG',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        jsonfield:fields."id"::String as "NUMBER",
        jsonfield:fields.CUST_PART_NO::String as CUST_PART_NO,
        jsonfield:fields.CUST_PART_DESCRIPTION::String as CUST_PART_DESCRIPTION,
        jsonfield:fields.TEA_FULL_PART_NO::String as TEA_FULL_PART_NO,
        jsonfield:fields.UNIT_PARTS::String as UNIT_PARTS,
        jsonfield:fields.CUR::String as CUR,
        jsonfield:fields.LIST_PRICE::NUMBER(38,2) as LIST_PRICE,
        jsonfield:fields.DC_RATE::NUMBER(38,2) as DC_RATE,
        jsonfield:fields.SURCHARGE::NUMBER(38,2) as SURCHARGE,
        jsonfield:fields.NET_PRICE::NUMBER(38,2) as NET_PRICE
    from {{ source('SHAREPOINT', 'SAS_GOLDEN_SAMSUNG') }} 
    where _FILEDATE = (select max(_FILEDATE) from {{ source('SHAREPOINT', 'SAS_GOLDEN_SAMSUNG') }})
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        "NUMBER",
        CUST_PART_NO,
        CUST_PART_DESCRIPTION,
        TEA_FULL_PART_NO,
        UNIT_PARTS,
        CUR,
        LIST_PRICE,
        DC_RATE,
        SURCHARGE,
        NET_PRICE
    from source_data
),

type_data as (
    select 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        _FILENAME,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        cast(_UPLOADDATE as TIMESTAMP_NTZ(9)) as _UPLOADDATE,
        "NUMBER",
        CUST_PART_NO,
        CUST_PART_DESCRIPTION,
        TEA_FULL_PART_NO,
        UNIT_PARTS,
        CUR,
        LIST_PRICE,
        DC_RATE,
        SURCHARGE,
        NET_PRICE
    from transform_data
)

select * from type_data