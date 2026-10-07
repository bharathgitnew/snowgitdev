/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.28"
*************/

{{ config(
      materialized='view',
      alias='PAID_SERVICE_SO_REQUEST',
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
    from {{ ref('ODS__MDM__PAID_SERVICE_SO_REQUEST') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data