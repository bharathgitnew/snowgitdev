/************
Model file generated from dbtGeneratePubViews: 09.21.2022.04.35.02"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU032_A901',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        KAPPL,
        KSCHL,
        VKORG,
        KUNNR,
        MATNR,
        DATBI,
        DATAB,
        KNUMH,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU032_A901') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data