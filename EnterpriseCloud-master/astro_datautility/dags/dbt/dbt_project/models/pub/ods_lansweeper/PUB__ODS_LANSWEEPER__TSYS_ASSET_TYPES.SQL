/************
Model file generated from dbtGeneratePubViews: 03.09.2022.17.40.39"
*************/

{{ config(
      materialized='view',
      alias='TSYS_ASSET_TYPES',
      transient=false
) }}

with source_data as (
    SELECT
        ASSET_TYPE,
        ASSET_TYPE_NAME,
        ASSET_TYPE_ICON_10,
        ASSET_TYPE_ICON_16,
        ASSET_TYPE_ICON_48,
        LAST_CHANGED,
        _FILEDATE
    from {{ ref('ODS__LANSWEEPER__TSYS_ASSET_TYPES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data