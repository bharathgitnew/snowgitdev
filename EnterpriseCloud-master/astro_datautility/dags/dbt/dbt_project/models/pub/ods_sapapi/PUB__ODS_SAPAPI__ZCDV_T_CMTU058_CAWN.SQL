/************
Model file generated from dbtGeneratePubViews: 11.10.2022.08.13.54"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU058_CAWN',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        ATINN,
        ATZHL,
        ADZHL,
        ATWRT,
        ATFLV,
        ATFLB,
        ATCOD,
        ATSTD,
        ATAWE,
        ATAW1,
        ATIDN,
        SPRAS,
        TXTNR,
        DATUV,
        TECHV,
        AENNR,
        LKENZ,
        DOKAR,
        DOKNR,
        DOKVR,
        DOKTL,
        ATZHH,
        KNOBJ,
        ATWHI,
        ATTLV,
        ATTLB,
        ATPRZ,
        ATINC,
        ATVPL,
        DATUB,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU058_CAWN') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data