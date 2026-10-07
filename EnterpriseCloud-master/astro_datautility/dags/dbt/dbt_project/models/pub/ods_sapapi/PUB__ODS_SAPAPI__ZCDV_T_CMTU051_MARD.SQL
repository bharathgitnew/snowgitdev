/************
Model file generated from dbtGeneratePubViews: 12.20.2022.08.45.44"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU051_MARD',
      transient=false
) }}

with source_data as (
    SELECT
        MATNR,
        WERKS,
        LGORT,
        PSTAT,
        LVORM,
        LFGJA,
        LFMON,
        SPERR,
        LABST,
        UMLME,
        INSME,
        EINME,
        SPEME,
        RETME,
        VMLAB,
        VMUML,
        VMINS,
        VMEIN,
        VMSPE,
        VMRET,
        KZILL,
        KZILQ,
        KZILE,
        KZILS,
        KZVLL,
        KZVLQ,
        KZVLE,
        KZVLS,
        DISKZ,
        LSOBS,
        LMINB,
        LBSTF,
        HERKL,
        EXPPG,
        EXVER,
        LGPBE,
        KLABS,
        KINSM,
        KEINM,
        KSPEM,
        DLINL,
        PRCTL,
        ERSDA,
        VKLAB,
        VKUML,
        LWMKB,
        BSKRF,
        MDRUE,
        MDJIN,
        DUMMY_STL_INCL_EEW_PS,
        FSH_SALLOC_QTY_S,
        CWM_LABST,
        CWM_INSME,
        CWM_EINME,
        CWM_SPEME,
        CWM_RETME,
        CWM_UMLME,
        CWM_KLABS,
        CWM_KINSM,
        CWM_KEINM,
        CWM_KSPEM,
        CWM_VMLAB,
        CWM_VMINS,
        CWM_VMEIN,
        CWM_VMSPE,
        CWM_VMRET,
        CWM_VMUML,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU051_MARD') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data