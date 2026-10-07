/************
Model file generated from dbtGeneratePubViews: 11.10.2022.04.59.34"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU046_COBK',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        KOKRS,
        BELNR,
        GJAHR,
        VERSN,
        VRGNG,
        TIMESTMP,
        PERAB,
        PERBI,
        BLDAT,
        BUDAT,
        CPUDT,
        USNAM,
        BLTXT,
        STFLG,
        STOKZ,
        REFBT,
        REFBN,
        REFBK,
        REFGJ,
        BLART,
        LDGRP,
        ORGVG,
        SUMBZ,
        DELBZ,
        WSDAT,
        KURST,
        VARNR,
        KWAER,
        CTYP1,
        CTYP2,
        CTYP3,
        CTYP4,
        AWTYP,
        AWORG,
        LOGSYSTEM,
        CPUTM,
        ALEBZ,
        ALEBN,
        AWSYS,
        AWREF_REV,
        AWORG_REV,
        AWKEY,
        VALDT,
        KOKRS_SENDER,
        BELNR_SENDER,
        LOGSYSTEM_SENDER,
        REPROCESSING_STATUS_CODE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU046_COBK') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data