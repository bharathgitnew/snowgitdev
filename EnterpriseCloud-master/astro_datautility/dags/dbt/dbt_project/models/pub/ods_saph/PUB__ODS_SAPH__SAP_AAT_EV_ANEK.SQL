/************
Model file generated from dbtGeneratePubViews: 03.13.2023.10.56.40"
*************/

{{ config(
      materialized='view',
      alias='SAP_AAT_EV_ANEK',
      transient=false
) }}

with source_data as (
    SELECT
        BUKRS,
        ANLN1,
        ANLN2,
        GJAHR,
        LNRAN,
        BLDAT,
        BUDAT,
        MONAT,
        CPUDT,
        CPUTM,
        AEDAT,
        UPDDT,
        USNAM,
        TCODE,
        BVORG,
        XBLNR,
        STBLG,
        STJAH,
        SGTXT,
        MENGE,
        MEINS,
        MEINS001,
        ANLU1,
        ANLU2,
        ANUPD,
        GLVOR,
        VBUND,
        PARGB,
        BUREG,
        AUGLZ,
        ABRBUP,
        OBART,
        OBJID,
        ZUONR,
        MWSKZ,
        EBELN,
        EBELP,
        MATNR,
        AUGLN,
        BELNR,
        BUZEI,
        BZDAT,
        XANTEI,
        AWTYP,
        AWORG,
        AWSYS,
        PBUKR,
        VORGN,
        LDGRP,
        DOCUMENT_UUID,
        TRANSACTION_UUID,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_AAT_EV_ANEK') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data