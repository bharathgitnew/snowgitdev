/************
Model file generated from dbtGeneratePubViews: 09.21.2022.04.35.01"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU031_A904',
      transient=false
) }}

with source_data as (
    SELECT
        KAPPL,
        KSCHL,
        KONDA,
        MATNR,
        DATBI,
        DATAB,
        KNUMH,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU031_A904') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data