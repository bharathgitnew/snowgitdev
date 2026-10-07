{{ config(
        alias='REPORTS_DAYS_OF_INVENTORY',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        transient=false
) }}

with source_data as 
(
    select 
        MATERIAL,
        PLANT,
        STORAGE_LOCATION,
        ON_HAND,
        MTH1,
        MTH2,
        MTH3,
        MTH4,
        MTH5,
        MTH6,
        MTH7,
        MTH8,
        MTH9,
        MTH10,
        MTH11,
        MTH12,
        DOI_12_MONTHS,
        DOI_3_MONTHS
    from {{ ref('SILVER__TEA_PLANNING__SAPH_DAYS_OF_INVENTORY_MASTER') }} 
    where SALES_INTEL_FLAG = TRUE
),

transform_data as
(
    select 
        MATERIAL,
        PLANT,
        STORAGE_LOCATION,
        ON_HAND,
        MTH1,
        MTH2,
        MTH3,
        MTH4,
        MTH5,
        MTH6,
        MTH7,
        MTH8,
        MTH9,
        MTH10,
        MTH11,
        MTH12,
        DOI_12_MONTHS,
        DOI_3_MONTHS,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
    from source_data
),

type_data as
(
    select 
        cast(AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
        cast(MATERIAL as VARCHAR(16777216)) as MATERIAL,
        cast(PLANT as VARCHAR(16777216)) as PLANT,
        cast(STORAGE_LOCATION as VARCHAR(16777216)) as STORAGE_LOCATION,
        cast(ON_HAND as NUMBER(38,10)) as ON_HAND,
        cast(MTH1 as NUMBER(38,10)) as MTH1,
        cast(MTH2 as NUMBER(38,10)) as MTH2,
        cast(MTH3 as NUMBER(38,10)) as MTH3,
        cast(MTH4 as NUMBER(38,10)) as MTH4,
        cast(MTH5 as NUMBER(38,10)) as MTH5,
        cast(MTH6 as NUMBER(38,10)) as MTH6,
        cast(MTH7 as NUMBER(38,10)) as MTH7,
        cast(MTH8 as NUMBER(38,10)) as MTH8,
        cast(MTH9 as NUMBER(38,10)) as MTH9,
        cast(MTH10 as NUMBER(38,10)) as MTH10,
        cast(MTH11 as NUMBER(38,10)) as MTH11,
        cast(MTH12 as NUMBER(38,10)) as MTH12,
        cast(DOI_12_MONTHS as NUMBER(38,10)) as DOI_12_MONTHS,
        cast(DOI_3_MONTHS as NUMBER(38,10)) as DOI_3_MONTHS
    from transform_data
)

select * from type_data