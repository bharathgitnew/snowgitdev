/************
Model file generated from dbtGeneratePubViews: 03.21.2023.07.27.19"
*************/

{{ config(
      materialized='view',
      alias='SAP_AAM_EV_ANLB',
      transient=false
) }}

with source_data as (
    SELECT
        BUKRS,
        ANLN1,
        ANLN2,
        AFABE,
        BDATU,
        ADATU,
        ERNAM,
        ERDAT,
        AENAM,
        AEDAT,
        XLOEV,
        XSPEB,
        FELEI,
        XNEGA,
        XGWGK,
        XUNTA,
        AFABG,
        ZINBG,
        SAFBG,
        INVSL,
        AFASL,
        NDJAR,
        NDPER,
        NAPRZ,
        SAPRZ,
        WBIND,
        ALIND,
        APROP,
        UMJAR,
        NDURJ,
        NDURP,
        SCHRW,
        WAERS,
        LGJAN,
        PERFY,
        ANUPD,
        AUFWTG,
        XAFBE,
        ANLGR,
        ANLGR2,
        VYEAR,
        VMNTH,
        INBDA,
        ABGDAT_B,
        J_1AARVKEY,
        J_1AALTDAT,
        J_1AALTIDX,
        SCHRW_PROZ,
        UMPER,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_AAM_EV_ANLB') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data