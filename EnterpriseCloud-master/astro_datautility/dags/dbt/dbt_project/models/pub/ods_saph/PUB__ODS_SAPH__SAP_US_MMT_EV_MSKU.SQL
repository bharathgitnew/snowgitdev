/************
Model file generated from dbtGeneratePubViews: 02.21.2023.08.07.05"
*************/

{{ config(
      materialized='view',
      alias='SAP_US_MMT_EV_MSKU',
      transient=false,
	  enabled=false
) }}

with source_data as (
    SELECT
        MATNR,
        WERKS,
        CHARG,
        SOBKZ,
        KUNNR,
        LFGJA,
        LFMON,
        KULAB,
        MEINS,
        KUINS,
        MEINS001,
        KUEIN,
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
    from {{ ref('ODS__SAPH__SAP_US_MMT_EV_MSKU') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data