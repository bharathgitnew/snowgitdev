/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.13.55"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONCOMMONDATA_BUCODEMAPPING',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        BUCODEBYCONFIGURATION,
        BUCODEOLD_TEA,
        BUCODETEA,
        BUCODETEL
    from {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_BUCODEMAPPING') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data