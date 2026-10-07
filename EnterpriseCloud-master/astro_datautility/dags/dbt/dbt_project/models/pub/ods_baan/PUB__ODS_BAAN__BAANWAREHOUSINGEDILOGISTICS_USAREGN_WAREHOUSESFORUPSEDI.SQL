/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.26"
*************/

{{ config(
      materialized='view',
      alias='BAANWAREHOUSINGEDILOGISTICS_USAREGN_WAREHOUSESFORUPSEDI',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ACCOUNTNO,
        TOBEUSEDBYXPTDESCRIPTION,
        TOBEUSEDBYXPTID,
        TOBEUSEDFORATWDESCRIPTION,
        TOBEUSEDFORATWID,
        UPSWAREHOUSE,
        WAREHOUSE
    from {{ ref('ODS__BAAN__BAANWAREHOUSINGEDILOGISTICS_USAREGN_WAREHOUSESFORUPSEDI') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data