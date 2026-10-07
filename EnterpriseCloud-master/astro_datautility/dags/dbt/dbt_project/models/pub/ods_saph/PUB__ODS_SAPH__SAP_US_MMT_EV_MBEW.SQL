/************
Model file generated from dbtGeneratePubViews: 02.23.2023.08.45.27"
*************/

{{ config(
      materialized='view',
      alias='SAP_US_MMT_EV_MBEW',
      transient=false
) }}

with source_data as (
    SELECT
        MATNR,
        BWKEY,
        LBKUM,
        MEINS,
        SALK3,
        WAERS,
        VPRSV,
        VERPR,
        WAERS001,
        STPRS,
        WAERS002,
        PEINH,
        BKLAS,
        LFGJA,
        LFMON,
        MEINS001,
        BUKRS,
        WAERS003,
        BWTAR,
        ZFPDT,
        MLAST,
        MLMAA,
        EKLAS,
        QKLAS,
        ZKPRS,
        WAERS004,
        ZKDAT,
        SALKV,
        WAERS005,
        EKALR,
        HKMAT,
        PPRDZ,
        PDATZ,
        PPRDL,
        PDATL,
        PPRDV,
        PDATV,
        LAEPR,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_US_MMT_EV_MBEW') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data