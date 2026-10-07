/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.35"
*************/

{{ config(
      materialized='view',
      alias='CONDITIONS_TRANSACTION_DATA',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
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
        KOUPD,
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
        KUNNR,
        KDIFF,
        KWERT,
        KSTEU,
        KINAK,
        KOAID,
        ZAEKO,
        KMXAW,
        KMXWR,
        KFAKTOR,
        KDUPL,
        KFAKTOR1,
        KZBZG,
        KSTBS,
        KONMS,
        KONWS,
        KAWRT_K,
        KWAEH,
        KWERT_K,
        KFKIV,
        KVARC,
        KMPRS,
        PRSQU,
        VARCOND,
        STUFE,
        WEGXX,
        KTREL,
        MDFLG,
        TXJLV,
        KBFLAG,
        KOLNR3,
        CPF_GUID,
        KAQTY,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__CONDITIONS_TRANSACTION_DATA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data