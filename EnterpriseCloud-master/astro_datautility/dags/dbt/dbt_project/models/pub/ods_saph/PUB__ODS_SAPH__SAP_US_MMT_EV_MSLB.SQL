/************
Model file generated from dbtGeneratePubViews: 02.21.2023.08.06.35"
*************/

{{ config(
      materialized='view',
      alias='SAP_US_MMT_EV_MSLB',
      transient=false
) }}

with source_data as (
    SELECT
        MATNR,
        WERKS,
        CHARG,
        SOBKZ,
        LIFNR,
        LFGJA,
        LFMON,
        LBLAB,
        MEINS,
        LBINS,
        MEINS001,
        LBEIN,
        MEINS002,
        MEINS003,
        BUKRS,
        WAERS,
        ZFPDT,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_US_MMT_EV_MSLB') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data