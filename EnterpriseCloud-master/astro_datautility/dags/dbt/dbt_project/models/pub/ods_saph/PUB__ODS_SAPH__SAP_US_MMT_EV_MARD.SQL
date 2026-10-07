/************
Model file generated from dbtGeneratePubViews: 10.11.2022.08.55.31"
*************/

{{ config(
      materialized='view',
      alias='SAP_US_MMT_EV_MARD',
      transient=false,
	  enabled=false
) }}

with source_data as (
    SELECT
        MATNR,
        WERKS,
        LGORT,
        LVORM,
        LFGJA,
        LFMON,
        LABST,
        MEINS,
        UMLME,
        MEINS001,
        INSME,
        MEINS002,
        EINME,
        MEINS003,
        SPEME,
        MEINS004,
        RETME,
        MEINS005,
        MEINS006,
        BUKRS,
        WAERS,
        ZFPDT,
        PSTAT,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_US_MMT_EV_MARD') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data