/************
Model file generated from dbtGeneratePubViews: 04.07.2023.03.06.41"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU200_TVLKT',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        SPRAS,
        LFART,
        VTEXT,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU200_TVLKT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data