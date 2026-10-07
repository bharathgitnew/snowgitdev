/************
Model file generated from dbtGeneratePubViews: 01.09.2023.04.53.52"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU029_PRCD_ELEMENTS',
      transient=false
) }}

with source_data as (
    SELECT
        KNUMV,
        KPOSN,
        STUNR,
        ZAEHK,
        KAPPL,
        KSCHL,
        KDATU,
        KRECH,
        KAWRT,
        KBETR,
        WAERS,
        KKURS,
        KPEIN,
        KMEIN,
        KUMZA,
        KUMNE,
        KNTYP,
        KSTAT,
        KNPRS,
        KRUEK,
        KRELI,
        KHERK,
        KGRPE,
        KOLNR,
        KNUMH,
        KOPOS,
        KVSL1,
        SAKN1,
        MWSK1,
        KVSL2,
        SAKN2,
        MWSK2,
        LIFNR,
        KDIFF,
        KWERT,
        WAERK,
        KSTEU,
        KINAK,
        KOAID,
        ZAEKO,
        KFAKTOR,
        KDUPL,
        KFAKTOR1,
        KZBZG,
        KSTBS,
        KONMS,
        KONWS,
        KWAEH,
        KWERT_K,
        KFKIV,
        KMPRS,
        PRSQU,
        TXJLV,
        KBFLAG,
        KOUPD,
        KMXAW,
        KMXWR,
        KAWRT_K,
        KUNNR,
        KVARC,
        VARCOND,
        KTREL,
        MDFLG,
        _DATAAGING,
        CPF_GUID,
        KAQTY,
        VAL_ZERO,
        IS_ACCT_DETN_RELEVANT,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU029_PRCD_ELEMENTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data