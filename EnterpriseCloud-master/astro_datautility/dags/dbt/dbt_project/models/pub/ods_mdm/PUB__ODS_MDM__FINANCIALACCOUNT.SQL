/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.21"
*************/

{{ config(
      materialized='view',
      alias='FINANCIALACCOUNT',
      transient=false
) }}

with source_data as (
    SELECT
        ACCOUNTID,
        PARENTACCOUNTID,
        ACCOUNTIDTYPE,
        OPERATOR,
        VALUETYPE,
        DEBITCREDITINDICATOR,
        SENSITIVEINDICATOR,
        CATEGORYNAME,
        GROUPNAME,
        STATEMENTTYPE,
        ACCOUNTTYPE,
        ERPINDICATOR,
        STATUTORYREPORTINGGROUP
    from {{ ref('ODS__MDM__FINANCIALACCOUNT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data