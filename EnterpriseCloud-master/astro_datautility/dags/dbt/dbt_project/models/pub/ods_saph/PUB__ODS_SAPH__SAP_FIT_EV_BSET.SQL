/************
Model file generated from dbtGeneratePubViews: 10.11.2022.08.55.26"
*************/

{{ config(
      materialized='view',
      alias='SAP_FIT_EV_BSET',
      transient=false
) }}

with source_data as (
    SELECT
        BUKRS,
        BELNR,
        GJAHR,
        BUZEI,
        MWSKZ,
        HKONT,
        TXGRP,
        SHKZG,
        HWBAS,
        WAERS,
        FWBAS,
        WAERS001,
        HWSTE,
        WAERS002,
        FWSTE,
        WAERS003,
        KTOSL,
        KNUMH,
        STCEG,
        EGBLD,
        EGLLD,
        TXJCD,
        H2STE,
        HWAE2,
        H3STE,
        HWAE3,
        H2BAS,
        HWAE2001,
        H3BAS,
        HWAE3001,
        KSCHL,
        STMDT,
        STMTI,
        MLDDT,
        KBETR,
        KONWA,
        STBKZ,
        LSTML,
        LWSTE,
        WAERS004,
        LWBAS,
        WAERS005,
        TXDAT,
        BUPLA,
        TXJDP,
        TXJLV,
        TAXPS,
        TXMOD,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_FIT_EV_BSET') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data