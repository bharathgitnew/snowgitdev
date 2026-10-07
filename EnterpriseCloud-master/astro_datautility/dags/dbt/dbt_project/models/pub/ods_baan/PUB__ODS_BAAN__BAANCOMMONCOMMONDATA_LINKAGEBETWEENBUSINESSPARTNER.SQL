{{ config(
      materialized='view',
      alias='BAANCOMMONCOMMONDATA_LINKAGEBETWEENBUSINESSPARTNER',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        NEWBUSINESSPARTNER,
        OLDBUSINESSPARTNER
    from {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_LINKAGEBETWEENBUSINESSPARTNER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data