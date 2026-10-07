/************
Model file generated from dbtGeneratePubViews: 11.03.2022.06.08.29"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU023_TVAKT',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        SPRAS,
        AUART,
        BEZEI,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU023_TVAKT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data