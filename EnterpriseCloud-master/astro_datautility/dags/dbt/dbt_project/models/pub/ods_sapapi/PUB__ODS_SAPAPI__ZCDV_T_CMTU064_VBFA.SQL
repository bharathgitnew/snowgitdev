/************
Model file generated from dbtGeneratePubViews: 11.08.2022.04.22.04"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU064_VBFA',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        RUUID,
        VBELV,
        POSNV,
        VBELN,
        POSNN,
        VBTYP_N,
        RFMNG,
        MEINS,
        RFWRT,
        WAERS,
        VBTYP_V,
        PLMIN,
        TAQUI,
        ERDAT,
        ERZET,
        MATNR,
        BWART,
        BDART,
        PLART,
        LGNUM,
        AEDAT,
        FKTYP,
        BRGEW,
        GEWEI,
        VOLUM,
        VOLEH,
        FPLNR,
        FPLTR,
        RFMNG_FLO,
        RFMNG_FLT,
        VRKME,
        ABGES,
        SOBKZ,
        SONUM,
        KZBEF,
        NTGEW,
        LOGSYS,
        WBSTA,
        CMETH,
        MJAHR,
        STUFE,
        _DATAAGING,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU064_VBFA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data