/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.27"
*************/

{{ config(
      materialized='view',
      alias='PAID_SERVICE_CUSTOMER_PO',
      transient=false
) }}

with source_data as (
    SELECT
        PO_NUMBER_2,
        PO_NUMBER_2_SO_NUMBER,
        PO_NUMBER,
        CUSTOMER_GROUP,
        FAB_2_PARENT_CUSTOMER_NAME,
        BUSINESS_ISSUING_PO,
        WORK_START,
        PLANNED_END_DATE,
        BU,
        FAB,
        CONFIG,
        SITE_SUPERVISOR,
        PO_AMOUNT,
        PO_AMT_CALCULATED,
        RECEIVED_DATE,
        PO_TYPE,
        PO_STATUS,
        QUOTE,
        PO_DESCRIPTION,
        CORRECT_PAYMENT_TERMS,
        ISSUED_TO_TEA,
        SIG_COMMENTS,
        TABLE_REFRESH_DATE
    from {{ ref('ODS__MDM__PAID_SERVICE_CUSTOMER_PO') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data