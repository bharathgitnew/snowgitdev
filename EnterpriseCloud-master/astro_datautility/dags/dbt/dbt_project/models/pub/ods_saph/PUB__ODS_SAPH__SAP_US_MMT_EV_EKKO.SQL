/************
Model file generated from dbtGeneratePubViews: 08.30.2022.06.46.45"
*************/

{{ config(
      materialized='view',
      alias='SAP_US_MMT_EV_EKKO',
      transient=false,
	  enabled=false
) }}

with source_data as (
    SELECT
        EBELN,
        BUKRS,
        BSTYP,
        BSART,
        LOEKZ,
        STATU,
        AEDAT,
        ERNAM,
        LIFNR,
        ZTERM,
        EKORG,
        EKGRP,
        WAERS,
        WKURS,
        BEDAT,
        ANGNR,
        IHRAN,
        VERKF,
        AUTLF,
        INCO1,
        KNUMV,
        MEMORY,
        INCO2_L,
        ZZPDDFO,
        ZZRFOI1,
        ZZRFOI2,
        ZZMIZZ,
        ZZPOCZZ,
        ZZORFZ,
        ZZANZ,
        ZZAIPZ,
        ZZPRRZ,
        ZZSCWN,
        ZZRRZZ,
        ZZSQNZ,
        ZZPORZ,
        ZZPODZ,
        ZZPADZ,
        ZZCADZ,
        ZZCRSD,
        ZZRRDZ,
        ZZPDFRC,
        ZZCBENO,
        ZZCBENM,
        ZZPENO,
        ZZSREN,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_US_MMT_EV_EKKO') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data