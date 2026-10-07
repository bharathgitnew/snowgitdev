/************
Model file generated from dbtGeneratePubViews: 11.22.2022.10.10.54"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU063_T001W',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        WERKS,
        NAME1,
        BWKEY,
        KUNNR,
        LIFNR,
        FABKL,
        NAME2,
        STRAS,
        PFACH,
        PSTLZ,
        ORT01,
        EKORG,
        VKORG,
        CHAZV,
        KKOWK,
        KORDB,
        BEDPL,
        LAND1,
        REGIO,
        COUNC,
        CITYC,
        ADRNR,
        IWERK,
        TXJCD,
        VTWEG,
        SPART,
        SPRAS,
        WKSOP,
        AWSLS,
        CHAZV_OLD,
        VLFKZ,
        BZIRK,
        ZONE1,
        TAXIW,
        BZQHL,
        LET01,
        LET02,
        LET03,
        TXNAM_MA1,
        TXNAM_MA2,
        TXNAM_MA3,
        BETOL,
        J_1BBRANCH,
        VTBFI,
        FPRFW,
        ACHVM,
        DVSART,
        NODETYPE,
        NSCHEMA,
        PKOSA,
        MISCH,
        MGVUPD,
        VSTEL,
        MGVLAUPD,
        MGVLAREVAL,
        SOURCING,
        NO_DEFAULT_BATCH_MANAGEMENT,
        FSH_MG_ARUN_REQ,
        FSH_SEAIM,
        FSH_BOM_MAINTENANCE,
        FSH_GROUP_PR,
        ARUN_FIX_BATCH,
        OILIVAL,
        OIHVTYPE,
        OIHCREDIPI,
        STORETYPE,
        DEP_STORE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU063_T001W') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data