/************
Model file generated from dbtGeneratePubViews: 09.13.2022.05.08.08"
*************/

{{ config(
      materialized='view',
      alias='SAP_US_FIT_EV_BKPFN',
      transient=false
) }}

with source_data as (
    SELECT
        BUKRS,
        BELNR,
        GJAHR,
        BLART,
        BLDAT,
        BUDAT,
        MONAT,
        MONAT_NUM,
        CPUDT,
        CPUTM,
        AEDAT,
        UPDDT,
        WWERT,
        USNAM,
        TCODE,
        BVORG,
        XBLNR,
        DBBLG,
        STBLG,
        STJAH,
        BKTXT,
        WAERS,
        KURSF,
        KZWRS,
        KZKRS,
        BSTAT,
        XNETB,
        XRUEB,
        GLVOR,
        GRPID,
        IBLAR,
        AWTYP,
        AWKEY,
        HWAER,
        XSTOV,
        STODT,
        AWSYS,
        STGRD,
        RLDNR,
        LDGRP,
        PPNAM,
        PPDAT,
        PPTME,
        TXKRS,
        CTXKRS,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_US_FIT_EV_BKPFN') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data