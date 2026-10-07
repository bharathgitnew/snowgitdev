/************
Model file generated from dbtGeneratePubViews: 10.18.2022.03.17.32"
*************/

{{ config(
      materialized='view',
      alias='SAP_ZZM_EV_CAWN',
      transient=false
) }}

with source_data as (
    SELECT
        ATINN,
        ADZHL,
        ATZHL,
        ATINN_INNER,
        ATWRT,
        ATFLV,
        ATFLB,
        ATCOD,
        ATSTD,
        ATAWE,
        ATAW1,
        ATIDN,
        SPRAS,
        TXTNR,
        DATUV,
        TECHV,
        AENNR,
        LKENZ,
        DOKAR,
        DOKNR,
        DOKVR,
        DOKTL,
        ATZHH,
        KNOBJ,
        ATWHI,
        ATTLV,
        ATTLB,
        ATPRZ,
        ATINC,
        ATVPL,
        ADATU,
        VDATU,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_ZZM_EV_CAWN') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data