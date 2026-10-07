/************
Model file generated from dbtGeneratePubViews: 04.08.2022.10.55.50"
*************/

{{ config(
      materialized='view',
      alias='SERVICECONTRACTSFLEXTSRS',
      transient=false
) }}

with source_data as (
    SELECT
        DOCUMENT_ID,
        REV_REC_DATE,
        REV_REC_MONTH,
        SOLD_TO_CODE,
        SERIAL_NUMBER,
        CONTRACT_NUMBER,
        SO_NUMBER,
        CUSTOMER,
        CUSTOMER_CODE,
        OFFICE,
        OFFICE_CODE,
        BU_CODE,
        PRODUCT_TYPE_CODE,
        FINANCE_TSR_HOURS,
        FINANCE_REVENUE_AMOUNT,
        TSR_HOURS,
        TSR_AMOUNT,
        MODIFIED,
        MODIFIED_BY,
        COMMENTS
    from {{ ref('COMMON__SHAREPOINT__SERVICECONTRACTSFLEXTSRS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data