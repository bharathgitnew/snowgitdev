{{ config(
        alias = 'TEA_PRICEBOOK',
        materialized='incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as (
    select
        _FILENAME,
        _FILEDATE,
        SUPPLIER_CODE,
        ITEM_CODE,
        BU_ITEM_CODE,
        DESCRIPTION,
        FACTORY_SALES,
        NOW_INTERNATIONAL_PRICE,
        NOW_US_LIST_PRICE,
        NOW_US_STRATEGY_DI,
        NOW_TEA_TRANSFER_PRICE,
        NOW_TEA_STRATEGY_DI,
        NEXT_INTERNATIONAL_PRICE,
        NEXT_US_LIST_PRICE,
        NEXT_US_STRATEGY_DI,
        NEXT_TEA_TRANSFER_PRICE,
        NEXT_TEA_STRATEGY_DI,
        GLOBAL_ABC_CLASSIFICATION_DI,
        TEA_ABC_CLASSIFICATION_DI,
        NOW_SALES_PRICE_EFFECTIVE_DATE,
        NOW_SALES_PRICE_EXPIRE_DATE,
        NOW_REGISTRATION_DATE,
        NOW_REGISTRATION_PERSON_NUMBER,
        NEXT_SALES_PRICE_EFFECTIVE_DATE,
        NEXT_SALES_PRICE_EXPIRE_DATE,
        NEXT_REGISTRATION_DATE,
        NEXT_REGISTRATION_PERSON_NUMBER 
    from {{ source('FILE', 'TEA_PRICEBOOK') }} 
    where _FILEDATE = (select max(_FILEDATE) from {{ source("FILE", "TEA_PRICEBOOK") }})

),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _FILENAME,
        _FILEDATE,
        SUPPLIER_CODE,
        ITEM_CODE,
        BU_ITEM_CODE,
        DESCRIPTION,
        FACTORY_SALES,
        NOW_INTERNATIONAL_PRICE,
        NOW_US_LIST_PRICE,
        NOW_US_STRATEGY_DI,
        NOW_TEA_TRANSFER_PRICE,
        NOW_TEA_STRATEGY_DI,
        NEXT_INTERNATIONAL_PRICE,
        NEXT_US_LIST_PRICE,
        NEXT_US_STRATEGY_DI,
        NEXT_TEA_TRANSFER_PRICE,
        NEXT_TEA_STRATEGY_DI,
        GLOBAL_ABC_CLASSIFICATION_DI,
        TEA_ABC_CLASSIFICATION_DI,
        NOW_SALES_PRICE_EFFECTIVE_DATE,
        NOW_SALES_PRICE_EXPIRE_DATE,
        NOW_REGISTRATION_DATE,
        NOW_REGISTRATION_PERSON_NUMBER,
        NEXT_SALES_PRICE_EFFECTIVE_DATE,
        NEXT_SALES_PRICE_EXPIRE_DATE,
        NEXT_REGISTRATION_DATE,
        NEXT_REGISTRATION_PERSON_NUMBER 
    from source_data
)
SELECT * FROM transform_data