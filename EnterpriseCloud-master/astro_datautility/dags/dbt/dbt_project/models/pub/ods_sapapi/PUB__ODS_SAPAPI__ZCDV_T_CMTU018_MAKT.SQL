/************
Model file generated from dbtGeneratePubViews: 11.08.2022.04.22.04"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU018_MAKT',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        MATNR,
        SPRAS,
        MAKTX,
        MAKTG,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU018_MAKT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data