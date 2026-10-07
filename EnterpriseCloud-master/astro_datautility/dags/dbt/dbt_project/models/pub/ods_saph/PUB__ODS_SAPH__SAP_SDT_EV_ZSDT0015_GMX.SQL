/************
Model file generated from dbtGeneratePubViews: 02.20.2023.06.07.04"
*************/

{{ config(
      materialized='view',
      alias='SAP_SDT_EV_ZSDT0015_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        VBELN,
        POSNR,
        PSPNR,
        VKORG,
        WERKS,
        UEPOS,
        ZITMGRP,
        PS_PSP_PNR,
        ZVBELNF,
        ZORTY,
        ZMTCZ,
        ZPRCODE,
        ZPRCD,
        AUART,
        PSTYV,
        ZSREQ,
        ZSRESF,
        ZCDZZ,
        ZCDAF,
        ZSSCZ,
        ZCSDIN,
        ZREDT,
        ZFCDT,
        ZSRDZ,
        ZTADZ,
        ZTADES,
        ZVCZZ,
        ZPOZZ,
        ZMSCZ,
        ZOASZ,
        ZVQNZ,
        ZPOCURR,
        ZOVDN,
        ZEBELP,
        ZSLDT,
        ZSEAS,
        ZESDT,
        ZESDF,
        ZNLDT,
        ZWAERS,
        ZWAERS001,
        ZCLDT,
        ZWAERS002,
        ZCUDZ,
        ZCUTZ,
        ZCUZZ,
        ZIEDC,
        ZIETC,
        ZUDCZ,
        ZUTCZ,
        ZCUNZ,
        ZUDSI,
        ZUISI,
        ZFL1001,
        ZFL1002,
        ZFL1003,
        ZFL1004,
        ZFL1005,
        ZREGDTM,
        ZUPDDTM,
        DEL_FLG,
        C_DATE,
        C_TIME,
        C_USER,
        C_PGM,
        U_DATE,
        U_TIME,
        U_USER,
        U_PGM,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_SDT_EV_ZSDT0015_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data