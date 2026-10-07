/************
Model file generated from dbtGeneratePubViews: 03.09.2023.04.53.33"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU171_TVM1T',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        SPRAS,
        MVGR1,
        BEZEI,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU171_TVM1T') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data