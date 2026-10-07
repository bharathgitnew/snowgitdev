/************
Model file generated from dbtGeneratePubViews: 03.09.2022.17.40.39"
*************/

{{ config(
      materialized='view',
      alias='TSYS_IP_LOCATIONS',
      transient=false
) }}

with source_data as (
    SELECT
        START_IP,
        END_IP,
        IP_LOCATION,
        REAL_START,
        REAL_END,
        PACKAGE_SHARE,
        SHARE_USERNAME,
        SHARE_PASSWORD,
        SHARE_KEY_HASH,
        LOCATION_ID,
        _FILEDATE
    from {{ ref('ODS__LANSWEEPER__TSYS_IP_LOCATIONS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data