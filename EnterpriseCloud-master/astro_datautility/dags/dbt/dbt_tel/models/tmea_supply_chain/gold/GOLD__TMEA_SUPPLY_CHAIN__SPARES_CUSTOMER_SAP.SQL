{{ config(
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        alias = 'SPARES_CUSTOMER_SAP',
        transient = false
) }}

with source_data as (
    select
        CLIENT AS CLIENT,
        CUSTOMER_NUMBER AS CUSTOMER_NUMBER,
        NAME_1 AS NAME,
        CITY AS CITY,
        REGION_STATE_PROVINCE_COUNTY AS REGION_STATE_PROVINCE_COUNTY,
        COUNTRY_KEY AS COUNTRY_KEY
    from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__GENERAL_DATA_IN_CUSTOMER_MASTER') }}
    where CLIENT = 300
),

transform_data as (
    select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        CLIENT,
        CUSTOMER_NUMBER,
        NAME,
        CITY,
        REGION_STATE_PROVINCE_COUNTY,
        COUNTRY_KEY
    from source_data
),

type_data as (
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(CLIENT AS VARCHAR(16777216)) AS CLIENT,
        CAST(CUSTOMER_NUMBER AS VARCHAR(16777216)) AS CUSTOMER_NUMBER,
        CAST(NAME AS VARCHAR(16777216)) AS NAME,
        CAST(CITY AS VARCHAR(16777216)) AS CITY,
        CAST(REGION_STATE_PROVINCE_COUNTY AS VARCHAR(16777216)) AS REGION_STATE_PROVINCE_COUNTY,
        CAST(COUNTRY_KEY AS VARCHAR(16777216)) AS COUNTRY_KEY
    from transform_data
)

select * from type_data