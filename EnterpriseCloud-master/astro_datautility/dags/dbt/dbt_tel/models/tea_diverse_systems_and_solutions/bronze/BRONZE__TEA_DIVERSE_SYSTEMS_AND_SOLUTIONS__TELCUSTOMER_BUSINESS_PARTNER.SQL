{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='TELCUSTOMER_BUSINESS_PARTNER',
    unique_key = ['BUSINESS_PARTNER_ID']
) }}

with source_data as
(
    SELECT
        _FILENAME
        ,_FILEDATE
        ,JSONFIELD:"BUSINESS_PARTNER_ID"::NUMBER AS BUSINESS_PARTNER_ID
        ,JSONFIELD:"NAME"::STRING AS NAME
        ,JSONFIELD:"CURRENCY_CODE"::STRING AS CURRENCY_CODE
        ,JSONFIELD:"BIS_CUSTOMER_CODE"::STRING AS BIS_CUSTOMER_CODE
        ,JSONFIELD:"TEL_REGION"::STRING AS TEL_REGION
        ,JSONFIELD:"PARENT_BUSINESS_PARTNER_ID"::NUMBER AS PARENT_BUSINESS_PARTNER_ID
        ,JSONFIELD:"ENG_NAME"::STRING AS ENG_NAME
        ,JSONFIELD:"ACCEPT_NDA"::NUMBER AS ACCEPT_NDA
        ,REGEXP_REPLACE(JSONFIELD:"NDA_MODIFIED_DATE", '\/Date\\(|\\)\/', '')::TIMESTAMP AS NDA_MODIFIED_DATE
        ,JSONFIELD:"NDA_MODIFIED_BY"::STRING AS NDA_MODIFIED_BY
    FROM {{ source("TELCUSTOMER", "BUSINESS_PARTNER") }}
    WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("TELCUSTOMER", "BUSINESS_PARTNER") }})
)

,transform_data as
(
    SELECT
        BUSINESS_PARTNER_ID,
        NAME,
        CURRENCY_CODE,
        BIS_CUSTOMER_CODE,
        TEL_REGION,
        PARENT_BUSINESS_PARTNER_ID,
        ENG_NAME,
        ACCEPT_NDA,
        NDA_MODIFIED_DATE,
        NDA_MODIFIED_BY,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _Row_Hash
    FROM source_data
)
,type_data as 
(
    select
        cast(BUSINESS_PARTNER_ID as NUMBER(38,0)) as BUSINESS_PARTNER_ID,
        cast(NAME as VARCHAR(16777216)) as NAME,
        cast(CURRENCY_CODE as VARCHAR(16777216)) as CURRENCY_CODE,
        cast(BIS_CUSTOMER_CODE as VARCHAR(16777216)) as BIS_CUSTOMER_CODE,
        cast(TEL_REGION as VARCHAR(16777216)) as TEL_REGION,
        cast(PARENT_BUSINESS_PARTNER_ID as NUMBER(38,0)) as PARENT_BUSINESS_PARTNER_ID,
        cast(ENG_NAME as VARCHAR(16777216)) as ENG_NAME,
        cast(ACCEPT_NDA as NUMBER(38,0)) as ACCEPT_NDA,
        cast(NDA_MODIFIED_DATE as TIMESTAMP_NTZ(9)) as NDA_MODIFIED_DATE,
        cast(NDA_MODIFIED_BY as VARCHAR(16777216)) as NDA_MODIFIED_BY,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data