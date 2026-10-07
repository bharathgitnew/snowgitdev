/************
Model file generated from dbtGeneratePubViews: 10.18.2022.03.17.23"
*************/

{{ config(
      materialized='view',
      alias='SAP_FIM_EV_KNB1',
      transient=false
) }}

with source_data as (
    SELECT
        KUNNR,
        BUKRS,
        PERNR,
        ERDAT,
        ERNAM,
        SPERR,
        LOEVM,
        ZUAWA,
        BUSAB,
        AKONT,
        BEGRU,
        KNRZE,
        KNRZB,
        ZAHLS,
        ZTERM,
        ZSABE,
        KVERM,
        HBKID,
        XVERR,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_FIM_EV_KNB1') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data