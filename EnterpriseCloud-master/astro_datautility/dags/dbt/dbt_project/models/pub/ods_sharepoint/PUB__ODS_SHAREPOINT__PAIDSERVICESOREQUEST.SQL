/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.41.24"
*************/

{{ config(
      materialized='view',
      alias='PAIDSERVICESOREQUEST',
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
        POINMODULECONFIGURATION
    from {{ ref('ODS__SHAREPOINT__PAIDSERVICESOREQUEST') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data