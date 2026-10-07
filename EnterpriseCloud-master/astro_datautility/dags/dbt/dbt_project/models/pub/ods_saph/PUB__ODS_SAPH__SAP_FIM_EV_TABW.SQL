/************
Model file generated from dbtGeneratePubViews: 02.20.2023.06.07.07"
*************/

{{ config(
      materialized='view',
      alias='SAP_FIM_EV_TABW',
      transient=false
) }}

with source_data as (
    SELECT
        BWASL,
        BWAGRP,
        XVERGA,
        XAKTIV,
        XDEAKT,
        XABGMM,
        XERLOS,
        XAVERB,
        XABUCH,
        BWAKON,
        XPRJKT,
        ANSHKZ,
        BWASLG,
        BLART,
        XABINV,
        BWASLN,
        GITTGR,
        XABGWG,
        XABIMM,
        XUSBWA,
        XUMBHI,
        XIFREL,
        XCOOBJ,
        XCOPSP,
        XAVERBN,
        XZUGBR,
        XUMJA,
        RSN_CODE,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_FIM_EV_TABW') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data