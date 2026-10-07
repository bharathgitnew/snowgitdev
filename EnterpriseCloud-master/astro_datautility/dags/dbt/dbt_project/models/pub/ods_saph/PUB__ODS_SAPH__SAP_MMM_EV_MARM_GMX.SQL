/************
Model file generated from dbtGeneratePubViews: 03.13.2023.10.56.32"
*************/

{{ config(
      materialized='view',
      alias='SAP_MMM_EV_MARM_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        MATNR,
        MEINH,
        UMREZ,
        UMREN,
        EANNR,
        EAN11,
        NUMTP,
        LAENG,
        MEABM,
        BREIT,
        MEABM001,
        HOEHE,
        MEABM002,
        MEABM003,
        VOLUM,
        VOLEH,
        VOLEH001,
        BRGEW,
        GEWEI,
        GEWEI001,
        MESUB,
        ATINN,
        MESRT,
        XFHDW,
        XBEWW,
        KZWSO,
        MSEHI,
        BFLME_MARM,
        GTIN_VARIANT,
        NEST_FTR,
        MAX_STACK,
        TOP_LOAD_FULL,
        TOP_LOAD_FULL_UOM,
        SPECNAME00000001,
        CAPAUSE,
        TY2TQ,
        DUMMY_UOM_INCL_EEW_PS,
        _CWM_TY2TQ,
        _STTPEC_NCODE,
        _STTPEC_NCODE_TY,
        _STTPEC_RCODE,
        _STTPEC_SERUSE,
        _STTPEC_SYNCCHG,
        _STTPEC_SERNO_MANAGED,
        _STTPEC_SERNO_PROV_BUP,
        _STTPEC_UOM_SYNC,
        PCBUT,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_MMM_EV_MARM_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data