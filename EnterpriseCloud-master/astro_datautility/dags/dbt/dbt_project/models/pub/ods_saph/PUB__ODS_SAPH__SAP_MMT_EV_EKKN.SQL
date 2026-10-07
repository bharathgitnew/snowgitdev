/************
Model file generated from dbtGeneratePubViews: 10.11.2022.08.55.29"
*************/

{{ config(
      materialized='view',
      alias='SAP_MMT_EV_EKKN',
      transient=false,
	  enabled=false
) }}

with source_data as (
    SELECT
        EBELN,
        EBELP,
        ZEKKN,
        LOEKZ,
        VBELN,
        VBELP,
        VETEN,
        LIFNR,
        LOEKZ001,
        LOEKZ002,
        SAKTO,
        KOKRS,
        KOSTL,
        AUFNR,
        PS_PSP_PNR,
        ANLN1,
        ANLN2,
        PRCTR,
        ZZUPDDT,
        ZZUPDTM,
        ZZOFFSETACCOUNT,
        ZZOFFSETDEPART,
        ZZOFFSETWBS,
        ZZCORPRATNINFO,
        ZZCORPORGRINFO,
        ZZMATCHRESLT,
        ZZBDKEY,
        ZZSEGMENTX,
        ZZSEGMENTY,
        ZZSEGMENTZ,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_MMT_EV_EKKN') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data