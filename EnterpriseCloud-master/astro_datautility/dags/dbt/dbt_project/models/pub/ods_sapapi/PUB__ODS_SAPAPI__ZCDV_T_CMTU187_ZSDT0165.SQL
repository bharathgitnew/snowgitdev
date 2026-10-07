/************
Model file generated from dbtGeneratePubViews: 03.17.2023.06.37.47"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU187_ZSDT0165',
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
        DELFLG,
        CDATE,
        CTIME,
        CUSER,
        CPGM,
        UTIME,
        UUSER,
        UPGM,
        UDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU187_ZSDT0165') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data