/************
Model file generated from dbtGeneratePubViews: 01.02.2023.23.58.19"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU106_MDMA',
      transient=false
) }}

with source_data as (
    SELECT
        MATNR,
        BERID,
        WERKS,
        DISPR,
        DISMM,
        DISPO,
        DISGR,
        MINBE,
        LFRHY,
        FXHOR,
        DISLS,
        RDPRF,
        BSTRF,
        BSTMI,
        BSTMA,
        MABST,
        TAKZT,
        AUSSS,
        SOBSL,
        LGPRO,
        LGFSB,
        MRPPP,
        EISBE,
        RWPRO,
        SHZET,
        BSTFE,
        LOSFX,
        LAGPR,
        LGRAD,
        PROPR,
        VRBMT,
        VRBDB,
        VRBDT,
        VRBFK,
        LOEKZ,
        SHPRO,
        AHDIS,
        AUTRU,
        PSTAT,
        KZKFK,
        SHFLG,
        APOKZ,
        PLIFZ,
        PLIFZX,
        SCMMATLOCIDGUID16,
        SCMMATLOCIDGUID22,
        SCMGRPRT,
        SCMGIPRT,
        SCMRRPTYPE,
        SCMHEURID,
        SCMPACKAGEID,
        SCMCONHAP,
        SCMHUNIT,
        SCMCONHAPOUT,
        SCMHUNITOUT,
        SCMRRPSELGROUP,
        SCMLSUOM,
        SCMREORDDUR,
        SCMTARGETDUR,
        SCMTSTRID,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU106_MDMA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data