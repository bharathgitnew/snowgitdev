/************
Model file generated from dbtGeneratePubViews: 09.21.2022.04.35.01"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU030_KONP',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        KNUMH,
        KOPOS,
        KAPPL,
        KSCHL,
        KNUMT,
        STFKZ,
        KZBZG,
        KSTBM,
        KONMS,
        KSTBW,
        KONWS,
        KRECH,
        KBETR,
        KONWA,
        KPEIN,
        KMEIN,
        PRSCH,
        KUMZA,
        KUMNE,
        MEINS,
        MXWRT,
        GKWRT,
        PKWRT,
        FKWRT,
        RSWRT,
        KWAEH,
        UKBAS,
        KZNEP,
        KUNNR,
        LIFNR,
        MWSK1,
        LOEVM_KO,
        ZAEHK_IND,
        BOMAT,
        KBRUE,
        KSPAE,
        BOSTA,
        KNUMA_PI,
        KNUMA_AG,
        KNUMA_SQ,
        VALTG,
        VALDT,
        ZTERM,
        ANZAUF,
        MIKBAS,
        MXKBAS,
        KOMXWRT,
        KLF_STG,
        KLF_KAL,
        VKKAL,
        AKTNR,
        KNUMA_BO,
        MWSK2,
        VERTT,
        VERTN,
        VBEWA,
        MDFLG,
        KFRST,
        UASTA,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU030_KONP') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data