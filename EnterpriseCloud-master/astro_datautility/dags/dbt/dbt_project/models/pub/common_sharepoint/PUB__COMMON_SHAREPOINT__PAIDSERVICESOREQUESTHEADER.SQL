/************
Model file generated from dbtGeneratePubViews: 04.08.2022.10.55.50"
*************/

{{ config(
      materialized='view',
      alias='PAIDSERVICESOREQUESTHEADER',
      transient=false
) }}

with source_data as (
    SELECT
        DOCUMENTID,
        SOREQUESTDATE,
        SONUMBER,
        REQUESTOR,
        CUSTOMERFABGROUP,
        CUSTOMERFABOFFICE,
        FAB,
        BU,
        PONUMBER,
        QUOTENUMBER,
        CUSTOMERFAB,
        ESTIMATEDHOURS,
        SOSTART,
        SOEND,
        BUSINESS,
        SERVICETYPE,
        DESCRIPTION,
        SERIALNUMBER,
        CREDITCHECK,
        DECOMISSION,
        REQUESTCOMMENTS,
        SIGCOMMENTS,
        FIELDUPDATES,
        SIGNOTESTOFIELD,
        TOTALTSRAMOUNTINPUT,
        INVOICINGSTATUS,
        TSRAMOUNT,
        POINMODULECONFIGURATION,
        SOREQUESTROWNUMBER
    from {{ ref('COMMON__SHAREPOINT__PAIDSERVICESOREQUESTHEADER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data