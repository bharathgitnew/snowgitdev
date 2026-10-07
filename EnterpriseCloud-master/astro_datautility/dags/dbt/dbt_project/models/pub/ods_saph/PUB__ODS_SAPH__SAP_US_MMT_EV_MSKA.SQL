/************
Model file generated from dbtGeneratePubViews: 02.21.2023.08.06.32"
*************/

{{ config(
      materialized='view',
      alias='SAP_US_MMT_EV_MSKA',
      transient=false,
	  enabled=false
) }}

with source_data as (
    SELECT
        MATNR,
        WERKS,
        LGORT,
        CHARG,
        SOBKZ,
        VBELN,
        POSNR,
        LFGJA,
        LFMON,
        KALAB,
        MEINS,
        KAINS,
        MEINS001,
        KASPE,
        MEINS002,
        KAEIN,
        MEINS003,
        MEINS004,
        BUKRS,
        WAERS,
        ZFPDT,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_US_MMT_EV_MSKA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data