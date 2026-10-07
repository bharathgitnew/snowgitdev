/************
Model file generated from dbtGeneratePubViews: 03.17.2023.06.37.51"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU016_ZSDT0163',
      transient=false
) }}

with source_data as (
    SELECT
        VBELN,
        POSNR,
        ZRSCZ,
        ZRFZZ,
        ZRNZZ,
        ZRANZ,
        ZRRNZ,
        ZRRAN,
        ZMCNNM,
        ZMCNNO,
        ZDRZZ,
        ZRSZZ,
        ZRQSN,
        ZRPSN,
        ZZRMTZ,
        ZZRCRZ,
        ZZSOWZZ,
        ZZIPRID,
        ZZITEM,
        ZZREQ,
        ZZSTATUS,
        ZZCAPSID,
        ZZCAT,
        ZZCOST,
        ZZIPRWBS,
        ZZMFCST,
        ZZRMCZ,
        DEL_FLG,
        C_DATE,
        C_TIME,
        C_USER,
        C_PGM,
        U_DATE,
        U_TIME,
        U_USER,
        U_PGM,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU016_ZSDT0163') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data