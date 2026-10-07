/************
Model file generated from dbtGeneratePubViews: 10.03.2022.08.31.45"
*************/

{{ config(
      materialized='view',
      alias='BAANV_TEA_ADDRESSES',
      transient=false
) }}

with source_data as (
    SELECT
        ADDRESS_CODE,
        NAME,
        NAME2,
        ADDRESS,
        ADDRESS2,
        HOUSE_NUMBER,
        CITY,
        CITY2,
        STATE_PROVINCE,
        COUNTRY,
        POSTAL_CODE,
        ROUTE,
        TELEPHONE,
        FAX
    from {{ ref('ODS__LEGACY93__BAANV_TEA_ADDRESSES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data