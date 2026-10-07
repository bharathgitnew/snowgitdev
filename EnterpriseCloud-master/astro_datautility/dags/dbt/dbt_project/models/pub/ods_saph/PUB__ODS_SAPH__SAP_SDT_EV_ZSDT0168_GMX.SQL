/************
Model file generated from dbtGeneratePubViews: 03.02.2023.08.55.56"
*************/

{{ config(
      materialized='view',
      alias='SAP_SDT_EV_ZSDT0168_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        SEQNO,
        PRC_STS,
        ZZREQID,
        ZZDATATYPE,
        VBELN,
        ZZVBELN,
        VKORG,
        VTXTK,
        KUNNR,
        ZECOZ,
        ZICOZ,
        ZZSCCD,
        ZZCUSMD,
        ZZCCCD,
        ZZDDZZ,
        ZKUNNRBP,
        ZZKUNNR,
        POSNR,
        ETENR,
        MATNR,
        ZZDEVI,
        ZZOINZ,
        ZZMTCZ,
        LFIMG,
        VRKME,
        VRKME001,
        ZDECAMT_ACT,
        ZASMBK_CUR,
        ZASMBK_CUR001,
        ZZPRCD,
        ZZPRCODE,
        ZZCOMPID,
        ZCOMP,
        ZCORI,
        ZEDUZ,
        ZCANFLG,
        ERNAM,
        SMTP_ADDR,
        ZZINZZ,
        ZZMAWB,
        ZZHAWB,
        Z_IF_REGDTM,
        Z_IF_UPDDTM,
        C_DATE,
        C_TIME,
        C_USER,
        C_PGM,
        U_DATE,
        U_TIME,
        U_USER,
        U_PGM,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_SDT_EV_ZSDT0168_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data