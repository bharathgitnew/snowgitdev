/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.41.24"
*************/

{{ config(
      materialized='view',
      alias='SERVICECONTRACTSFLEXTSRS',
      transient=false
) }}

with source_data as (
    SELECT
        DOCUMENTID,
        REVRECDATE,
        REVRECMONTH,
        SOLDTOCODE,
        SERIALNUMBER,
        CONTRACTNUMBER,
        SONUMBER,
        CUSTOMER,
        CUSTOMERCODE,
        OFFICE,
        OFFICECODE,
        BUCODE,
        PRODUCTTYPECODE,
        FINANCETSRHOURS,
        FINANCEREVENUEAMOUNT,
        TSRHOURS,
        TSRAMOUNT,
        MODIFIEDBY,
        COMMENTS,
        MODIFIED
    from {{ ref('ODS__SHAREPOINT__SERVICECONTRACTSFLEXTSRS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data