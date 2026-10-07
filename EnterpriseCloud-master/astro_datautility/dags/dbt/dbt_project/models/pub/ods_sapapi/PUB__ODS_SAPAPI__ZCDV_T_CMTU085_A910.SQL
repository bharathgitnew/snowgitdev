/************
Model file generated from dbtGeneratePubViews: 01.02.2023.23.58.18"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU085_A910',
      transient=false
) }}

with source_data as (
    SELECT
        KAPPL,
        KSCHL,
        ZPLAND,
        MATNR,
        DATBI,
        DATAB,
        KNUMH,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU085_A910') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data