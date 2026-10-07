/************
Model file generated from dbtGeneratePubViews: 03.02.2023.08.55.44"
*************/

{{ config(
      materialized='view',
      alias='SAP_COM_EV_AUFK',
      transient=false
) }}

with source_data as (
    SELECT
        AUFNR,
        AUART,
        AUTYP,
        REFNR,
        ERNAM,
        ERDAT,
        AENAM,
        AEDAT,
        KTEXT,
        LTEXT,
        BUKRS,
        WERKS,
        GSBER,
        KOKRS,
        CCKEY,
        KOSTV,
        STORT,
        SOWRK,
        ASTKZ,
        PDAT1,
        PDAT2,
        PDAT3,
        IDAT1,
        IDAT2,
        IDAT3,
        OBJID,
        LOEKZ,
        KAPPL,
        KALSM,
        ZSCHL,
        ABKRS,
        KSTAR,
        KOSTL,
        SAKNR,
        SDATE,
        USER0,
        USER2,
        USER5,
        USER6,
        USER7,
        USER8,
        OBJNR,
        PRCTR,
        PSPEL,
        AWSLS,
        ABGSL,
        FUNC_AREA,
        SCOPE,
        AKSTL,
        ANFAUFNR,
        STATUS_CMPL,
        STATUS_CONCAT,
        STATUS_CRTD,
        STATUS_DLFL,
        STATUS_INVALID,
        STATUS_LKD,
        MATNR,
        PROJN,
        KDAUF,
        KDPOS,
        VAPLZ,
        WAWRK,
        USER4,
        WAERS,
        ERFZEIT,
        AEZEIT,
        ASTNR,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_COM_EV_AUFK') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data