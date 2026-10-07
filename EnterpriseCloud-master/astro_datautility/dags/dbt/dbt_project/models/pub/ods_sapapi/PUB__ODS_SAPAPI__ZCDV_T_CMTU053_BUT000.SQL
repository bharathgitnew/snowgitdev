/************
Model file generated from dbtGeneratePubViews: 11.10.2022.04.59.34"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU053_BUT000',
      transient=false
) }}

with source_data as (
    SELECT
        CLIENT,
        PARTNER,
        TYPE,
        BPKIND,
        BU_GROUP,
        BPEXT,
        BU_SORT1,
        BU_SORT2,
        SOURCE,
        TITLE,
        XDELE,
        XBLCK,
        AUGRP,
        TITLE_LET,
        BU_LOGSYS,
        CONTACT,
        NOT_RELEASED,
        NOT_LG_COMPETENT,
        PRINT_MODE,
        BP_EEW_DUMMY,
        ZZCORPORATION,
        ZZOFFICE,
        RATE,
        NAME_ORG1,
        NAME_ORG2,
        NAME_ORG3,
        NAME_ORG4,
        LEGAL_ENTY,
        IND_SECTOR,
        LEGAL_ORG,
        FOUND_DAT,
        LIQUID_DAT,
        LOCATION_1,
        LOCATION_2,
        LOCATION_3,
        PARTGRPTYP,
        NAME_GRP1,
        NAME_GRP2,
        MC_NAME1,
        MC_NAME2,
        CRUSR,
        CRDAT,
        CRTIM,
        CHUSR,
        CHDAT,
        CHTIM,
        PARTNER_GUID,
        ADDRCOMM,
        TD_SWITCH,
        IS_ORG_CENTRE,
        DB_KEY,
        VALID_FROM,
        VALID_TO,
        XPCPT,
        NATPERS,
        MILVE,
        NUC_SEC,
        PAR_REL,
        BP_SORT,
        KBANKS,
        KBANKL,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU053_BUT000') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data