/************
Model file generated from dbtGeneratePubViews: 02.23.2023.08.45.27"
*************/

{{ config(
      materialized='view',
      alias='SAP_US_MMT_EV_QBEW',
      transient=false
) }}

with source_data as (
    SELECT
        MATNR,
        BWKEY,
        BWTAR,
        SOBKZ,
        PSPNR,
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
        ZFPDT,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_US_MMT_EV_QBEW') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data