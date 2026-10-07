/************
Model file generated from dbtGeneratePubViews: 03.13.2023.10.56.30"
*************/

{{ config(
      materialized='view',
      alias='SAP_FIM_EV_BNKA',
      transient=false
) }}

with source_data as (
    SELECT
        BANKS,
        BANKL,
        ERDAT,
        ERNAM,
        BANKA,
        PROVZ,
        STRAS,
        ORT01,
        SWIFT,
        BGRUP,
        XPGRO,
        LOEVM,
        BNKLZ,
        PSKTO,
        ADRNR,
        BRNCH,
        CHKME,
        VERS,
        BICKY,
        RCCODE,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_FIM_EV_BNKA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data