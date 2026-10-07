/************
Model file generated from dbtGeneratePubViews: 10.11.2022.08.55.27"
*************/

{{ config(
      materialized='view',
      alias='SAP_US_MMT_EV_EKES',
      transient=false,
	  enabled=false
) }}

with source_data as (
    SELECT
        EBELN,
        EBELP,
        ETENS,
        EBTYP,
        EINDT,
        LPEIN,
        UZEIT,
        ERDAT,
        EZEIT,
        MENGE,
        MEINS,
        DABMG,
        MEINS001,
        ESTKZ,
        LOEKZ,
        KZDIS,
        XBLNR,
        VBELN,
        VBELP,
        MPROF,
        EMATN,
        MAHNZ,
        CHARG,
        UECHA,
        REF_ETENS,
        IMWRK,
        VBELN_ST,
        VBELP_ST,
        HANDOVERDATE,
        HANDOVERTIME,
        EKORG,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_US_MMT_EV_EKES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data