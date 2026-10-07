/************
Model file generated from dbtGeneratePubViews: 02.23.2023.08.45.23"
*************/

{{ config(
      materialized='view',
      alias='SAP_US_MMT_EV_MSSA',
      transient=false
) }}

with source_data as (
    SELECT
        BUKRS,
        WAERS,
        PERIV,
        MATNR,
        WERKS,
        SOBKZ,
        VBELN,
        POSNR,
        LFGJA,
        LFMON,
        SALAB,
        MEINS,
        SAINS,
        MEINS001,
        SASPE,
        MEINS002,
        SAEIN,
        MEINS003,
        ERSDA,
        KZBWS,
        SATRA,
        MEINS004,
        SARUE,
        MEINS005,
        ZFPDT,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_US_MMT_EV_MSSA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data