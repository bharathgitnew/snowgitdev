/************
Model file generated from dbtGeneratePubViews: 11.10.2022.08.13.55"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU057_INOB',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        CUOBJ,
        KLART,
        OBTAB,
        OBJEK,
        ROBTAB,
        ROBJEK,
        CLINT,
        STATU,
        CUCOZHL,
        PARENT,
        ROOT,
        EXPERTE,
        MATNR,
        DATUV,
        TECHS,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU057_INOB') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data