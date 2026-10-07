/************
Model file generated from dbtGeneratePubViews: 03.24.2023.05.34.26"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU123_T023T',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        SPRAS,
        MATKL,
        WGBEZ,
        WGBEZ60,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU123_T023T') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data