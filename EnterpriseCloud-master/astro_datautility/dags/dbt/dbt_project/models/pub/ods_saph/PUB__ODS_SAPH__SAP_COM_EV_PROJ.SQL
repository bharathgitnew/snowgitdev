/************
Model file generated from dbtGeneratePubViews: 09.13.2022.05.08.06"
*************/

{{ config(
      materialized='view',
      alias='SAP_COM_EV_PROJ',
      transient=false
) }}

with source_data as (
    SELECT
        PSPNR,
        POST1,
        OBJNR,
        ERNAM,
        ERDAT,
        AENAM,
        AEDAT,
        KIMSK,
        AUTOD,
        STSPD,
        STSPR,
        VERNR,
        VERNA,
        ASTNR,
        ASTNA,
        VBUKR,
        VGSBR,
        VKOKR,
        PRCTR,
        PWHIE,
        ZUORD,
        TRMEQ,
        PLFAZ,
        PLSEZ,
        WERKS,
        KALID,
        TXTSP,
        KOSTL,
        KTRG,
        SCOPE,
        XSTAT,
        PSPID,
        ZTEHT,
        SPROG,
        EPROG,
        STORT,
        PROFL,
        BPROF,
        PPROF,
        ZSCHM,
        IMPRF,
        ABGSL,
        SMPRF,
        PARGR,
        VPROF,
        SCPRF,
        SCHTYP,
        VGPLF,
        EWPLF,
        TXJCD,
        PLINT,
        BESTA,
        GRTOP,
        VKORG,
        VTWEG,
        SPART,
        DPPPROF,
        AEDTE,
        AEDTP,
        POSTU,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_COM_EV_PROJ') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data