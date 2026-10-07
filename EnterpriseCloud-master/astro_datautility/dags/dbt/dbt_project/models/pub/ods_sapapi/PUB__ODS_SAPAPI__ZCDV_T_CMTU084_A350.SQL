/************
Model file generated from dbtGeneratePubViews: 01.24.2023.05.18.36"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU084_A350',
      transient=false
) }}

with source_data as (
    SELECT
        KAPPL,
        KSCHL,
        VKORG,
        KFRST,
        DATBI,
        DATAB,
        KBSTAT,
        KNUMH,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU084_A350') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data