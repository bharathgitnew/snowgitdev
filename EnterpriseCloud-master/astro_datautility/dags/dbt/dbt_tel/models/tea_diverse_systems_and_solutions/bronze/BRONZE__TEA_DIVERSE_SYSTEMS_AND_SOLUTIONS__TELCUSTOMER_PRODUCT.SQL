{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TELCUSTOMER_PRODUCT'
) }}

with source_data as
(
    SELECT
        _FILENAME
        ,_FILEDATE
        ,JSONFIELD:"PRODUCT_ID"::NUMBER AS PRODUCT_ID
        ,JSONFIELD:"TEL_REGION"::STRING AS TEL_REGION
        ,JSONFIELD:"PART_NBR"::STRING AS PART_NBR
        ,JSONFIELD:"PRODUCT_DESCR"::STRING AS PRODUCT_DESCR
        ,JSONFIELD:"DISABLED"::NUMBER AS DISABLED
        ,JSONFIELD:"DELETED"::NUMBER AS DELETED
    FROM {{ source("TELCUSTOMER", "PRODUCT") }}
        WHERE _FILEDATE = (select max(_FILEDATE) from {{ source("TELCUSTOMER", "PRODUCT") }})
)

,transform_data as
(
    SELECT
        PRODUCT_ID,
        TEL_REGION,
        PART_NBR,
        PRODUCT_DESCR,
        DISABLED,
        DELETED,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _Row_Hash
    FROM source_data
)

,type_data as 
(
    select
        cast(PRODUCT_ID as NUMBER(38,0)) as PRODUCT_ID,
        cast(TEL_REGION as VARCHAR(16777216)) as TEL_REGION,
        cast(PART_NBR as VARCHAR(16777216)) as PART_NBR,
        cast(PRODUCT_DESCR as VARCHAR(16777216)) as PRODUCT_DESCR,
        cast(DISABLED as NUMBER(38,0)) as DISABLED,
        cast(DELETED as NUMBER(38,0)) as DELETED,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data