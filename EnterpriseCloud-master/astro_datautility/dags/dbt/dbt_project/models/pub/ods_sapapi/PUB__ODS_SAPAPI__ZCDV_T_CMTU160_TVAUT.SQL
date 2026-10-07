/************
Model file generated from dbtGeneratePubViews: 01.12.2023.09.12.11"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU160_TVAUT',
      transient=false
) }}

with source_data as (
    SELECT
        SPRAS,
        AUGRU,
        BEZEI,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU160_TVAUT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data