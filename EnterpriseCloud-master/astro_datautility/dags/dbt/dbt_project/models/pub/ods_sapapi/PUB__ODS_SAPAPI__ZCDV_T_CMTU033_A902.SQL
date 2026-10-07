/************
Model file generated from dbtGeneratePubViews: 10.20.2022.07.24.28"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU033_A902',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        KAPPL,
        KSCHL,
        VKORG,
        MATNR,
        DATBI,
        DATAB,
        KNUMH,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU033_A902') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data