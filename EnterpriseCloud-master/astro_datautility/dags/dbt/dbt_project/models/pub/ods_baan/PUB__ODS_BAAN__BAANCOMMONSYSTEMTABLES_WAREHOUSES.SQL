/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.04"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONSYSTEMTABLES_WAREHOUSES',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ADDRECEIPTMTRDESCRIPTION,
        ADDRECEIPTMTRID,
        ADDRESSCODE,
        BUSINESSPARTNER,
        DESCRIPTION,
        FINCOMP,
        NETTABLEWAREHOUSEDESCRIPTION,
        NETTABLEWAREHOUSEID,
        NONBLANKREFERENCEDESCRIPTION,
        NONBLANKREFERENCEID,
        PROJECT,
        WAREHOUSE,
        WAREHOUSECATERYDESCRIPTION,
        WAREHOUSECATERYID,
        WAREHOUSETYPEDESCRIPTION,
        WAREHOUSETYPEID
    from {{ ref('ODS__BAAN__BAANCOMMONSYSTEMTABLES_WAREHOUSES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data