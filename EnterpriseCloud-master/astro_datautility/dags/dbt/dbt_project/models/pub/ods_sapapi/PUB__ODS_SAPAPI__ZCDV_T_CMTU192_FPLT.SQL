/************
Model file generated from dbtGeneratePubViews: 01.24.2023.11.32.42"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU192_FPLT',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        FPLNR,
        FPLTR,
        FPTTP,
        TETXT,
        FKDAT,
        FPFIX,
        FAREG,
        FPROZ,
        WAERS,
        KURFP,
        FAKWR,
        FAKSP,
        FKARV,
        FKSAF,
        PERIO,
        FPLAE,
        MLSTN,
        MLBEZ,
        ZTERM,
        KUNRG,
        TAXK1,
        TAXK2,
        TAXK3,
        TAXK4,
        TAXK5,
        TAXK6,
        TAXK7,
        TAXK8,
        TAXK9,
        VALTG,
        VALDT,
        NFDAT,
        TEMAN,
        FAKCA,
        AFDAT,
        NETWR,
        NETPR,
        WAVWR,
        KZWI1,
        KZWI2,
        KZWI3,
        KZWI4,
        KZWI5,
        KZWI6,
        CMPRE,
        SKFBP,
        BONBA,
        PRSOK,
        TYPZM,
        CMPREFLT,
        UELNR,
        UELTR,
        KURRF,
        CCACT,
        KORTE,
        OFKDAT,
        DESCR,
        POSTPR,
        REFDOC,
        SETBYFINAL,
        ITEMUSAGE,
        DBKEY,
        PARENTKEY,
        DATAAGING,
        AD04FAREG,
        PEROPBEG,
        PEROPEND,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU192_FPLT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data