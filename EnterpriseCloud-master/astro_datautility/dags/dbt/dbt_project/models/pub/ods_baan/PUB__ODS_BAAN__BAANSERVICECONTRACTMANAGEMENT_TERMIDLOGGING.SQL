/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.21"
*************/

{{ config(
      materialized='view',
      alias='BAANSERVICECONTRACTMANAGEMENT_TERMIDLOGGING',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        APPLICATIONDESCRIPTION,
        APPLICATIONID,
        CONFIGURATION,
        CONTRACTEFFECTIVEDATE,
        CONTRACTEXPIRYDATE,
        CONTRACTQUOTATION,
        CONTRACTTEMPLATE,
        DATEOFPOSTINGTOHISTORY,
        DEFINITIONDATE,
        DELETIONDATE,
        LOGINOFDEFINEDBY,
        LOGINOFDELETEDBY,
        LOGINOFPOSTEDBY,
        OBJECT,
        OBJECTNUMBER,
        SERVICECONTRACT,
        SERVICEORDERQUOTATION,
        TERMID,
        WARRANTY
    from {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_TERMIDLOGGING') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data