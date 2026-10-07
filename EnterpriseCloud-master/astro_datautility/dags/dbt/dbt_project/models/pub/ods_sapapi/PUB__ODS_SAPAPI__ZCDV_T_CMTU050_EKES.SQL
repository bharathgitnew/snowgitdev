/************
Model file generated from dbtGeneratePubViews: 12.20.2022.08.45.43"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU050_EKES',
      transient=false
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
        DABMG,
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
        SGT_SCAT,
        MSGTSTMP,
        CWM_MENGE,
        CWM_DABMG,
        _DATAAGING,
        FSH_SALLOC_QTY,
        ORMNG,
        TMS_REF_UUID,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU050_EKES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data