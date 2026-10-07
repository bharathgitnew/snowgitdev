/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.41.23"
*************/

{{ config(
      materialized='view',
      alias='PAIDSERVICEQUOTE',
      transient=false
) }}

with source_data as (
    SELECT
        DOCUMENTID,
        QUOTENUMBER,
        SOREQUESTED,
        QUOTEDATE,
        CONFIGURATION,
        PRODUCTLINE,
        FABLOCATION,
        PONUMBER,
        ESTIMATEDTOTAL,
        REQUESTORNAME,
        CUSTOMER,
        STARTTIME,
        ENDTIME,
        WORKDESCRIPTION,
        DECOMISSION,
        QUOTESTATUS,
        CUSTOMERGROUP,
        SERIALNUMBER,
        TOOLID,
        PROBABILITY
    from {{ ref('ODS__SHAREPOINT__PAIDSERVICEQUOTE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data