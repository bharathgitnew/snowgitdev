/************
Model file generated from dbtGeneratePubViews: 04.21.2023.06.07.31"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU208_WYT3',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        LIFNR,
        EKORG,
        LTSNR,
        WERKS,
        PARVW,
        PARZA,
        ERNAM,
        ERDAT,
        LIFN2,
        DEFPA,
        PERNR,
        PARNR,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU208_WYT3') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data