/************
Model file generated from dbtGeneratePubViews: 03.16.2022.09.47.02"
*************/

{{ config(
      materialized='view',
      alias='CAPITAL_PO_HEADER',
      transient=false
) }}

with source_data as (
    SELECT
        MESSAGE_ID,
        FILENAME,
        PO_NUMBER,
        PO_DATE,
        PO_TYPE,
        DOCUMENT_FUNCTION,
        COMMENTS,
        CURRENCY,
        AMOUNT,
        ACCOUNT_NUMBER,
        PAYMENT_CONDITION,
        NET_TERMS_DAYS,
        PERCENT_DUE,
        DISCOUNT_DAYS,
        DISCOUNT_PERCENT,
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
        DATA_LOAD_DATE,
        PIP,
        REV,
        TEL_PO_STATUS,
        ADDITIONAL_EMAIL,
        OVERALL_STATUS,
        REASON,
        LAST_UPDATED_BY,
        WORKED_BY,
        BU,
        SUPPLIER_ID,
        STATUS_DT,
        SUB_BU,
        PURCHASING_TYPE,
        PART_ORDER,
        LAST_MODIFIED_BY_DT,
        FILE_CREATION_DATE,
        PROV_STATUS,
        PAYMENT_CONDITION2,
        NET_TERMS_DAYS2,
        PERCENT_DUE2,
        DISCOUNT_DAYS2,
        DISCOUNT_PERCENT2,
        PROP_INFO
    from {{ ref('ODS__TELCUSTOMER__CAPITAL_PO_HEADER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data