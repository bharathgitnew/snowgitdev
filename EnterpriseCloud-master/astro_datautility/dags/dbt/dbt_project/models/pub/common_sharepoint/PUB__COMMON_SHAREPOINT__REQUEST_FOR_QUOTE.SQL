{{ config(
      materialized='view',
      alias='REQUEST_FOR_QUOTE',
      transient=false
) }}

with source_data as (
    SELECT
        TITLE,
        DESCRIPTION,
        NRE_X0020_DETAILS_X002F_COST,
        REQUEST_X0020_TYPE,
        STATUS,
        Next_x0020_Action,
        NEXT_X0020_ACTION_X0020_REQUIRED,
        ACTION_X0020_DUE_X0020_DATE,
        QUOTE_X0020_DELIVERED,
        PO_X0020_EXPECTED_X0020_DATE,
        SPEC_X0020_SIGNED,
        ENGINEERING_X0020_EST_X0020_RECI,
        REVENUE,
        RFQ_UPDATE,
        ANTICIPATED_X0020_DELIVERY_X0020,
        RFQID,
        CUSTOMERREQCONTACT,
        ASSOCIATEDTOOLSERIALNU,
        CUSTOMERINITIALREQDATE,
        TMEAREQUESTOR,
        REQUESTDATE,
        PRIORITY,
        IFOTHERCUSTOMER,
        GENPO_X0020_SALES_X0020_EMAIL,
        GENPO_X0020_SERVICE_X0020_CONTAC,
        CUSTOMER,
        TECHMARKETINGCONTACT,
        SALESREPCONTACT,
        EARID,
        NEXTACTIONSTATUSLOG,
        INTERNAL,
        REGION,
        BUDGET,
        WAFERSIZE,
        CUSTOMERPRODUCT,
        DELIVERYDATEREQUEST,
        QUOTECOMMITEDBY,
        EARSUBMITTEDDATE,
        RFQTITLE,
        PRODUCT,
        CIPAPPROVALTIMESTAMP,
        MODIFIED,
        CREATED,
        AUTHOR,
        EDITOR,
        APPROVEDDATE
    from {{ ref('COMMON__SHAREPOINT__REQUEST_FOR_QUOTE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data