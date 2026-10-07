/************
Model file generated from dbtGeneratePubViews: 01.30.2023.09.30.51"
*************/

{{ config(
      materialized='view',
      alias='SAP_SDT_EV_VBFA_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        RUUID,
        VBELV,
        POSNV,
        VBELN,
        POSNN,
        VBTYP_N,
        RFMNG,
        MEINS,
        MEINS001,
        RFWRT,
        WAERS,
        WAERS001,
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
        GEWEI001,
        VOLUM,
        VOLEH,
        VOLEH001,
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
        GEWEI002,
        LOGSYS,
        WBSTA,
        CMETH,
        MJAHR,
        STUFE,
        _DATAAGING,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_SDT_EV_VBFA_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data