/************
Model file generated from dbtGeneratePubViews: 03.13.2023.10.56.43"
*************/

{{ config(
      materialized='view',
      alias='SAP_FIM_EV_T052',
      transient=false
) }}

with source_data as (
    SELECT
        ZTERM,
        ZTAGG,
        ZDART,
        ZFAEL,
        ZMONA,
        ZTAG1,
        ZPRZ1,
        ZTAG2,
        ZPRZ2,
        ZTAG3,
        ZSTG1,
        ZSMN1,
        ZSTG2,
        ZSMN2,
        ZSTG3,
        ZSMN3,
        XZBRV,
        ZSCHF,
        XCHPB,
        TXN08,
        ZLSCH,
        XCHPM,
        KOART,
        XSPLT,
        XSCRC,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_FIM_EV_T052') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data