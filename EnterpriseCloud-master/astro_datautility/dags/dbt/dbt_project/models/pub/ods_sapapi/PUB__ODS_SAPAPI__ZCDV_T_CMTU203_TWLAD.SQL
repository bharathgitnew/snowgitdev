/************
Model file generated from dbtGeneratePubViews: 04.21.2023.06.07.25"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU203_TWLAD',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        WERKS,
        LGORT,
        LFDNR,
        ADRNR,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU203_TWLAD') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data