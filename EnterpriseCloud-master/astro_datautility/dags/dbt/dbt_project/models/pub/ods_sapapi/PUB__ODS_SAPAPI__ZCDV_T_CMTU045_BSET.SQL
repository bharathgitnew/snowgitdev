/************
Model file generated from dbtGeneratePubViews: 11.10.2022.04.59.31"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU045_BSET',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        BUKRS,
        BELNR,
        GJAHR,
        BUZEI,
        MWSKZ,
        HKONT,
        TXGRP,
        SHKZG,
        HWBAS,
        FWBAS,
        HWSTE,
        FWSTE,
        KTOSL,
        KNUMH,
        STCEG,
        EGBLD,
        EGLLD,
        TXJCD,
        H2STE,
        H3STE,
        H2BAS,
        H3BAS,
        KSCHL,
        STMDT,
        STMTI,
        MLDDT,
        KBETR,
        STBKZ,
        LSTML,
        LWSTE,
        LWBAS,
        TXDAT,
        BUPLA,
        TXJDP,
        TXJLV,
        TAXPS,
        TXMOD,
        _DATAAGING,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU045_BSET') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data