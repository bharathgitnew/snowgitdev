{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TELCUSTOMER_CAPITAL_PO_HEADER',
    unique_key = []
) }}

-- Full Refresh is Records from Latest File
-- Incremental is Records from Latest File

with source_data as
(
    SELECT
         _FILENAME
        ,_FILEDATE
        ,JSONFIELD:"MESSAGE_ID"::STRING AS MESSAGE_ID
        ,JSONFIELD:"FILENAME"::STRING AS FILENAME
        ,JSONFIELD:"PO_NUMBER"::STRING AS PO_NUMBER
        ,REGEXP_REPLACE(JSONFIELD:"PO_DATE", '\/Date\\(|\\)\/', '')::TIMESTAMP AS PO_DATE
        ,JSONFIELD:"PO_TYPE"::STRING AS PO_TYPE
        ,JSONFIELD:"DOCUMENT_FUNCTION"::STRING AS DOCUMENT_FUNCTION
        ,JSONFIELD:"COMMENTS"::STRING AS COMMENTS
        ,JSONFIELD:"CURRENCY"::STRING AS CURRENCY
        ,JSONFIELD:"AMOUNT"::NUMBER AS AMOUNT
        ,JSONFIELD:"ACCOUNT_NUMBER"::STRING AS ACCOUNT_NUMBER
        ,JSONFIELD:"PAYMENT_CONDITION"::STRING AS PAYMENT_CONDITION
        ,JSONFIELD:"NET_TERMS_DAYS"::NUMBER AS NET_TERMS_DAYS
        ,JSONFIELD:"PERCENT_DUE"::NUMBER AS PERCENT_DUE
        ,JSONFIELD:"DISCOUNT_DAYS"::NUMBER AS DISCOUNT_DAYS
        ,JSONFIELD:"DISCOUNT_PERCENT"::NUMBER AS DISCOUNT_PERCENT
        ,JSONFIELD:"CONTACT_NAME"::STRING AS CONTACT_NAME
        ,JSONFIELD:"CONTACT_EMAIL"::STRING AS CONTACT_EMAIL
        ,JSONFIELD:"CONTACT_PHONE"::STRING AS CONTACT_PHONE
        ,JSONFIELD:"BILL_TO_LOCATION_ID"::STRING AS BILL_TO_LOCATION_ID
        ,JSONFIELD:"BILL_TO_NAME"::STRING AS BILL_TO_NAME
        ,JSONFIELD:"BILL_TO_ADDRESS_1"::STRING AS BILL_TO_ADDRESS_1
        ,JSONFIELD:"BILL_TO_ADDRESS_2"::STRING AS BILL_TO_ADDRESS_2
        ,JSONFIELD:"BILL_TO_ADDRESS_3"::STRING AS BILL_TO_ADDRESS_3
        ,JSONFIELD:"BILL_TO_CITY"::STRING AS BILL_TO_CITY
        ,JSONFIELD:"BILL_TO_REGION"::STRING AS BILL_TO_REGION
        ,JSONFIELD:"BILL_TO_COUNTRY"::STRING AS BILL_TO_COUNTRY
        ,JSONFIELD:"BILL_TO_POSTAL_CODE"::STRING AS BILL_TO_POSTAL_CODE
        ,REGEXP_REPLACE(JSONFIELD:"DATA_LOAD_DATE", '\/Date\\(|\\)\/', '')::TIMESTAMP AS DATA_LOAD_DATE
        ,JSONFIELD:"PIP"::STRING AS PIP
        ,JSONFIELD:"REV"::NUMBER AS REV
        ,JSONFIELD:"TEL_PO_STATUS"::STRING AS TEL_PO_STATUS
        ,JSONFIELD:"ADDITIONAL_EMAIL"::STRING AS ADDITIONAL_EMAIL
        ,JSONFIELD:"OVERALL_STATUS"::STRING AS OVERALL_STATUS
        ,JSONFIELD:"REASON"::STRING AS REASON
        ,JSONFIELD:"LAST_UPDATED_BY"::NUMBER AS LAST_UPDATED_BY
        ,JSONFIELD:"WORKED_BY"::NUMBER AS WORKED_BY
        ,JSONFIELD:"BU"::STRING AS BU
        ,JSONFIELD:"SUPPLIER_ID"::STRING AS SUPPLIER_ID
        ,REGEXP_REPLACE(JSONFIELD:"STATUS_DT", '\/Date\\(|\\)\/', '')::TIMESTAMP AS STATUS_DT
        ,JSONFIELD:"SUB_BU"::STRING AS SUB_BU
        ,JSONFIELD:"PURCHASING_TYPE"::STRING AS PURCHASING_TYPE
        ,JSONFIELD:"PART_ORDER"::NUMBER AS PART_ORDER
        ,REGEXP_REPLACE(JSONFIELD:"last_modified_by_dt", '\/Date\\(|\\)\/', '')::TIMESTAMP AS LAST_MODIFIED_BY_DT
        ,REGEXP_REPLACE(JSONFIELD:"file_creation_date", '\/Date\\(|\\)\/', '')::TIMESTAMP AS FILE_CREATION_DATE
        ,JSONFIELD:"prov_status"::STRING AS PROV_STATUS
        ,JSONFIELD:"PAYMENT_CONDITION2"::STRING AS PAYMENT_CONDITION2
        ,JSONFIELD:"NET_TERMS_DAYS2"::NUMBER AS NET_TERMS_DAYS2
        ,JSONFIELD:"PERCENT_DUE2"::NUMBER AS PERCENT_DUE2
        ,JSONFIELD:"DISCOUNT_DAYS2"::NUMBER AS DISCOUNT_DAYS2
        ,JSONFIELD:"DISCOUNT_PERCENT2"::NUMBER AS DISCOUNT_PERCENT2
        ,JSONFIELD:"PROP_INFO"::STRING AS PROP_INFO
    FROM {{ source("TELCUSTOMER", "CAPITAL_PO_HEADER") }}
    WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("TELCUSTOMER", "CAPITAL_PO_HEADER") }})
)
,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID
        ,SHA2('hash_me') AS _ROW_HASH
        ,source_data.MESSAGE_ID
        ,source_data.FILENAME
        ,source_data.PO_NUMBER
        ,source_data.PO_DATE
        ,source_data.PO_TYPE
        ,source_data.DOCUMENT_FUNCTION
        ,source_data.COMMENTS
        ,source_data.CURRENCY
        ,source_data.AMOUNT
        ,source_data.ACCOUNT_NUMBER
        ,source_data.PAYMENT_CONDITION
        ,source_data.NET_TERMS_DAYS
        ,source_data.PERCENT_DUE
        ,source_data.DISCOUNT_DAYS
        ,source_data.DISCOUNT_PERCENT
        ,source_data.CONTACT_NAME
        ,source_data.CONTACT_EMAIL
        ,source_data.CONTACT_PHONE
        ,source_data.BILL_TO_LOCATION_ID
        ,source_data.BILL_TO_NAME
        ,source_data.BILL_TO_ADDRESS_1
        ,source_data.BILL_TO_ADDRESS_2
        ,source_data.BILL_TO_ADDRESS_3
        ,source_data.BILL_TO_CITY
        ,source_data.BILL_TO_REGION
        ,source_data.BILL_TO_COUNTRY
        ,source_data.BILL_TO_POSTAL_CODE
        ,source_data.DATA_LOAD_DATE
        ,source_data.PIP
        ,source_data.REV
        ,source_data.TEL_PO_STATUS
        ,source_data.ADDITIONAL_EMAIL
        ,source_data.OVERALL_STATUS
        ,source_data.REASON
        ,source_data.LAST_UPDATED_BY
        ,source_data.WORKED_BY
        ,source_data.BU
        ,source_data.SUPPLIER_ID
        ,source_data.STATUS_DT
        ,source_data.SUB_BU
        ,source_data.PURCHASING_TYPE
        ,source_data.PART_ORDER
        ,source_data.LAST_MODIFIED_BY_DT
        ,source_data.FILE_CREATION_DATE
        ,source_data.PROV_STATUS
        ,source_data.PAYMENT_CONDITION2
        ,source_data.NET_TERMS_DAYS2
        ,source_data.PERCENT_DUE2
        ,source_data.DISCOUNT_DAYS2
        ,source_data.DISCOUNT_PERCENT2
        ,source_data.PROP_INFO
    FROM source_data
)
,type_data as
(
    select
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        MESSAGE_ID,
        FILENAME,
        PO_NUMBER,
        cast(PO_DATE as TIMESTAMP_NTZ(9)) as PO_DATE,
        PO_TYPE,
        DOCUMENT_FUNCTION,
        COMMENTS,
        CURRENCY,
        cast(AMOUNT as NUMBER(38,0)) as AMOUNT,
        ACCOUNT_NUMBER,
        PAYMENT_CONDITION,
        cast(NET_TERMS_DAYS as NUMBER(38,0)) as NET_TERMS_DAYS,
        cast(PERCENT_DUE as NUMBER(38,0)) as PERCENT_DUE,
        cast(DISCOUNT_DAYS as NUMBER(38,0)) as DISCOUNT_DAYS,
        cast(DISCOUNT_PERCENT as NUMBER(38,0)) as DISCOUNT_PERCENT,
        CONTACT_NAME,
        CONTACT_EMAIL,
        CONTACT_PHONE,
        BILL_TO_LOCATION_ID,
        BILL_TO_NAME,
        BILL_TO_ADDRESS_1,
        BILL_TO_ADDRESS_2,
        BILL_TO_ADDRESS_3,
        BILL_TO_CITY,
        BILL_TO_REGION,
        BILL_TO_COUNTRY,
        BILL_TO_POSTAL_CODE,
        cast(DATA_LOAD_DATE as TIMESTAMP_NTZ(9)) as DATA_LOAD_DATE,
        PIP,
        cast(REV as NUMBER(38,0)) as REV,
        TEL_PO_STATUS,
        ADDITIONAL_EMAIL,
        OVERALL_STATUS,
        REASON,
        cast(LAST_UPDATED_BY as NUMBER(38,0)) as LAST_UPDATED_BY,
        cast(WORKED_BY as NUMBER(38,0)) as WORKED_BY,
        BU,
        SUPPLIER_ID,
        cast(STATUS_DT as TIMESTAMP_NTZ(9)) as STATUS_DT,
        SUB_BU,
        PURCHASING_TYPE,
        cast(PART_ORDER as NUMBER(38,0)) as PART_ORDER,
        cast(LAST_MODIFIED_BY_DT as TIMESTAMP_NTZ(9)) as LAST_MODIFIED_BY_DT,
        cast(FILE_CREATION_DATE as TIMESTAMP_NTZ(9)) as FILE_CREATION_DATE,
        PROV_STATUS,
        PAYMENT_CONDITION2,
        cast(NET_TERMS_DAYS2 as NUMBER(38,0)) as NET_TERMS_DAYS2,
        cast(PERCENT_DUE2 as NUMBER(38,2)) as PERCENT_DUE2,
        cast(DISCOUNT_DAYS2 as NUMBER(38,0)) as DISCOUNT_DAYS2,
        cast(DISCOUNT_PERCENT2 as NUMBER(38,2)) as DISCOUNT_PERCENT2,
        PROP_INFO
    from transform_data
    )
select * from type_data