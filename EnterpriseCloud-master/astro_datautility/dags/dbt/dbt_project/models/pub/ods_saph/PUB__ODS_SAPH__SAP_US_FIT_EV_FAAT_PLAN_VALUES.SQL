/************
Model file generated from dbtGeneratePubViews: 09.29.2022.10.34.56"
*************/

{{ config(
      materialized='view',
      alias='SAP_US_FIT_EV_FAAT_PLAN_VALUES',
      transient=false
) }}

with source_data as (
    SELECT
        BUKRS,
        ANLN1,
        ANLN2,
        GJAHR,
        AFABE,
        POPER,
        SLALITTYPE,
        LDGRP,
        ANLGR,
        ANLGR2,
        MOVCAT,
        HSL,
        KSL,
        OSL,
        VSL,
        BSL,
        CSL,
        DSL,
        ESL,
        FSL,
        GSL,
        RHCUR,
        RKCUR,
        ROCUR,
        RVCUR,
        RBCUR,
        RCCUR,
        RDCUR,
        RECUR,
        RFCUR,
        RGCUR,
        ANLKL,
        KTOGR,
        XANLGR,
        XUNULL,
        XPOST,
        RECID,
        MIG_SOURCE,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_US_FIT_EV_FAAT_PLAN_VALUES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data