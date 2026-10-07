/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.13.57"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONCOMMONDATA_SAPARIBAPARENTMASTER',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ARIBANETWORKID,
        DUNS,
        NAME,
        PARENTBUSINESSPARTNER
    from {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_SAPARIBAPARENTMASTER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data