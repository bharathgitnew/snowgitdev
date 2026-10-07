/************
Model file generated from dbtGeneratePubViews: 01.24.2023.05.18.37"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU191_FPLA',
      transient=false
) }}

with source_data as (
    SELECT
        FPLNR,
        FPTYP,
        BPCAT,
        FPART,
        SORTL,
        BEDAT,
        ENDAT,
        HORIZ,
        VBELN,
        BEDAR,
        ENDAR,
        PERIO,
        FPLAE,
        RFPLN,
        LODAT,
        AUTTE,
        LODAR,
        PERAF,
        FAKCA,
        TNDAT,
        TNDAR,
        AUFPL,
        APLZL,
        RSNUM,
        RSPOS,
        EBELN,
        FPLTU,
        AUST1,
        AUST2,
        AUST3,
        AUST4,
        AUST5,
        BASISWRT,
        WAERS,
        PSPNR,
        AUTKOR,
        STATUS,
        FINAL,
        DBKEY,
        DATAAGING,
        IFRS15RELEVANCE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU191_FPLA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data