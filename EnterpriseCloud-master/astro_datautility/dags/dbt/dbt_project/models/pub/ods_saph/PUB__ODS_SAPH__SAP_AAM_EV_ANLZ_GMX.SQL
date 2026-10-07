/************
Model file generated from dbtGeneratePubViews: 03.02.2023.08.55.49"
*************/

{{ config(
      materialized='view',
      alias='SAP_AAM_EV_ANLZ_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        BUKRS,
        ANLN1,
        ANLN2,
        BDATU,
        ADATU,
        KOSTL,
        WERKS,
        GSBER,
        LSTAR,
        MSFAK,
        XSTIL,
        STORT,
        CAUFN,
        PLAN1,
        PLAN2,
        RAUMN,
        IAUFN,
        IPROJ,
        TPLKZ,
        TPLNR,
        ANUPD,
        TXJCD,
        IPSNR,
        KFZKZ,
        PERNR,
        KOSTLV,
        FISTL,
        GEBER,
        FKBER,
        GRANT_NBR,
        GEBER2,
        FKBER2,
        GRANT_NBR2,
        FISTL2,
        IMKEY,
        PS_PSP_PNR2,
        BUDGET_PD,
        BUDGET_PD2,
        SEGMENT,
        PRCTR,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_AAM_EV_ANLZ_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data