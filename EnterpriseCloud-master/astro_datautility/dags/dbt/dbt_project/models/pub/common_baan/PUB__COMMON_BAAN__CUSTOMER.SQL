/************
Model file generated from dbtGeneratePubViews: 04.08.2022.10.56.59"
*************/

{{ config(
      materialized='view',
      alias='CUSTOMER',
      transient=false
) }}

with source_data as (
    SELECT
        CUSTOMERID,
        CUSTOMERNAME,
        CUSTOMERSHORTNAME,
        ADDRESSID,
        TAXID,
        ISCUSTOMER,
        ISCUSTOMERSITE,
        ISINTEL,
        ISINVOICETO,
        ISSHIPTO,
        ISSOLDTO,
        ISPAYBY,
        ISACTIVE,
        ISINTERNAL,
        GROUPNAME,
        TELGROUPNAME,
        FINANCIALGROUPNAME,
        SALESGROUPNAME,
        REGION,
        SALESGROUPNAME_FST
    from {{ ref('COMMON__BAAN__CUSTOMER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data