/************
Model file generated from dbtGeneratePubViews: 12.22.2022.11.30.25"
*************/

{{ config(
      materialized='view',
      alias='SAP_US_SDT_EV_PRCD_ELEMENTS',
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
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_US_SDT_EV_PRCD_ELEMENTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data