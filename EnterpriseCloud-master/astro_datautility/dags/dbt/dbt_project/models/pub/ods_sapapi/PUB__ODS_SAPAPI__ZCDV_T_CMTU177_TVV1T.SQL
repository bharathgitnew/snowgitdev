/************
Model file generated from dbtGeneratePubViews: 01.12.2023.09.12.14"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU177_TVV1T',
      transient=false
) }}

with source_data as (
    SELECT
        SPRAS,
        KVGR1,
        BEZEI,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU177_TVV1T') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data