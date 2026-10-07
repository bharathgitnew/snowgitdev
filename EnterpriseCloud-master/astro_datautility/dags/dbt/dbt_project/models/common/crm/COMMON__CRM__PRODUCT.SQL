{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='PRODUCT',
    unique_key = ['PRODUCT_ID']
) }}

with source_data as
(
    SELECT
WO_COM_PRODUCTLINE.ID AS PRODUCT_ID,
WO_COM_PRODUCTLINE.COM_BUNAME AS PRODUCT_NAME

FROM
 {{ ref('ODS__CRM_FILE__COM_PRODUCTLINE') }} WO_COM_PRODUCTLINE
)

,transform_data as
(
    SELECT
    PRODUCT_ID,
    PRODUCT_NAME,
    '{{ invocation_id }}' AS AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
    FROM source_data

)
,type_data as
(
    select
        cast(PRODUCT_ID as VARCHAR(16777216)) as PRODUCT_ID,
        cast(PRODUCT_NAME as VARCHAR(16777216)) as PRODUCT_NAME,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data