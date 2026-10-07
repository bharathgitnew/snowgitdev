/************
Model file generated from dbtGeneratePubViews: 01.17.2023.05.02.37"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU155_TVAGT',
      transient=false
) }}

with source_data as (
    SELECT
        SPRAS,
        ABGRU,
        BEZEI,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU155_TVAGT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data