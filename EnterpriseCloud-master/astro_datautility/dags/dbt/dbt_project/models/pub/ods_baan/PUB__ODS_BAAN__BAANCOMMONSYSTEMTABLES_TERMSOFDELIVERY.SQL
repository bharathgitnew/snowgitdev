/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.04"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONSYSTEMTABLES_TERMSOFDELIVERY',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        CARRIAGEPAIDDESCRIPTION,
        CARRIAGEPAIDID,
        CASHONDELIVERYDESCRIPTION,
        CASHONDELIVERYID,
        DESCRIPTION,
        POINTOFTITLEPASSAGEDESCRIPTION,
        POINTOFTITLEPASSAGEID,
        TERMSOFDELIVERY,
        TERMSOFDELIVERYTEXT
    from {{ ref('ODS__BAAN__BAANCOMMONSYSTEMTABLES_TERMSOFDELIVERY') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data