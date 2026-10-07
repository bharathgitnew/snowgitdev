/************
Model file generated from dbtGeneratePubViews: 03.02.2023.08.55.46"
*************/

{{ config(
      materialized='view',
      alias='SAP_AAM_EV_ANLU_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        BUKRS,
        ANLN1,
        ANLN2,
        ZZFEEKBN,
        ZZLIFNR,
        ZZLEASEFEE,
        WAERS,
        ZZDATBI,
        ZZDATAB,
        ZZCOUNT,
        ZZCOMMENT,
        ZZADDRESS1,
        ZZADDRESS2,
        ZZADDRESS3,
        ZZCONDTION,
        ZZPOSTCD,
        ZZLOANER,
        ZZLOANBUKACD,
        ZZCAPSNO,
        ZZOLDASSETNO,
        ZZRINGINO,
        ZZYOBI1,
        ZZYOBI2,
        ZZYOBI3,
        ZZYOBI4,
        ZZYOBI5,
        DUMMY_FAA_MD_EEW_PS,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_AAM_EV_ANLU_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data