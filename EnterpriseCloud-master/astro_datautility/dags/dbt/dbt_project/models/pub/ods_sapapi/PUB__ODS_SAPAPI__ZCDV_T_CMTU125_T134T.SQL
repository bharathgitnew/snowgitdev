/************
Model file generated from dbtGeneratePubViews: 03.24.2023.05.34.26"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU125_T134T',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        SPRAS,
        MTART,
        MTBEZ,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU125_T134T') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data