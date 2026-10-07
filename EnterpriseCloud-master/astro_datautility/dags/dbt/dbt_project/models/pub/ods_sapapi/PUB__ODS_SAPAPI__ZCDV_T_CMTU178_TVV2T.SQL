/************
Model file generated from dbtGeneratePubViews: 01.12.2023.09.12.15"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU178_TVV2T',
      transient=false
) }}

with source_data as (
    SELECT
        SPRAS,
        KVGR2,
        BEZEI,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU178_TVV2T') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data