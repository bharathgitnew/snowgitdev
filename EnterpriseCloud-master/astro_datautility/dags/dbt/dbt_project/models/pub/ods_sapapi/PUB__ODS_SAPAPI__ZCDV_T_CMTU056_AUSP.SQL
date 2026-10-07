/************
Model file generated from dbtGeneratePubViews: 11.10.2022.04.59.31"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU056_AUSP',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        OBJEK,
        ATINN,
        ATZHL,
        MAFID,
        KLART,
        ADZHL,
        ATWRT,
        ATFLV,
        ATAWE,
        ATFLB,
        ATAW1,
        ATCOD,
        ATTLV,
        ATTLB,
        ATPRZ,
        ATINC,
        ATAUT,
        AENNR,
        DATUV,
        LKENZ,
        ATIMB,
        ATZIS,
        ATSRT,
        ATVGLART,
        DATUB,
        DEC_VALUE_FROM,
        DEC_VALUE_TO,
        CURR_VALUE_FROM,
        CURR_VALUE_TO,
        CURRENCY,
        DATE_FROM,
        DATE_TO,
        TIME_FROM,
        TIME_TO,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU056_AUSP') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data