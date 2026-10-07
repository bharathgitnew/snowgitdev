/************
Model file generated from dbtGeneratePubViews: 04.05.2022.12.11.12"
*************/

{{ config(
      materialized='view',
      alias='PAIDSERVICESOREQUEST',
      transient=false
) }}

with source_data as (
    SELECT
        SOREQUEST_DATE,
        SO_NUMBER,
        REQUESTOR,
        CUSTOMER_FAB_2_CUSTOMER_GROUP,
        CUSTOMER_FAB_2_OFFICE,
        FAB,
        BU,
        PONUMBER,
        QUOTE_NUMBER,
        CUSTOMER_FAB_2,
        EST_HOURS,
        SOSTART,
        SOEND,
        BUSINESS,
        SERVICE_TYPE,
        DESCRIPTION,
        SN,
        CREDIT_CHECK,
        DECOM,
        REQUEST_COMMENTS,
        SIG_COMMENTS,
        UPDATES_FROM_FIELD,
        SIG_NOTES_TO_FIELD,
        TOTAL_TSRAMOUNT_INPUT,
        ATTACHMENT_ADDED,
        INVOICING_STATUS,
        TSR_AMT,
        CONFIG,
        TABLE_REFRESH_DATE
    from {{ ref('COMMON__MDM__PAIDSERVICESOREQUEST') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data