/************
Model file generated from dbtGeneratePubViews: 02.20.2023.06.07.11"
*************/

{{ config(
      materialized='view',
      alias='SAP_SDT_EV_ZSDT0165_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        ZZREQID,
        ZZDVONO,
        ZZDVOINO,
        ZZCOMPID,
        ZZMATNR,
        ZZCOMPCD,
        ZZNEWFLG,
        ZZGCST,
        ZZGRSZ,
        ZZGDSZ,
        ZZGDMZ,
        ZZHZMT,
        ZZHSEP,
        ZZHSIP,
        ZZCLSS,
        ZZECCN,
        ZZSHREI,
        ZZHSDESEX,
        ZZHSDESIM,
        ZZELNO,
        ZZELTY,
        ZZATMA,
        ZZEXPC,
        ZZIMPC,
        ZREGDTM,
        ZUPDDTM,
        DEL_FLG,
        C_DATE,
        C_TIME,
        C_USER,
        C_PGM,
        U_DATE,
        U_TIME,
        U_USER,
        U_PGM,
        VKORG,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_SDT_EV_ZSDT0165_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data