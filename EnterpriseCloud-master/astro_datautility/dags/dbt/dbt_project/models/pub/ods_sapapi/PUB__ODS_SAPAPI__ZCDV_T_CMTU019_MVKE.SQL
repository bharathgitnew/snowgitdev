/************
Model file generated from dbtGeneratePubViews: 12.20.2022.05.19.52"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU019_MVKE',
      transient=false
) }}

with source_data as (
    SELECT
        MATNR,
        VKORG,
        VTWEG,
        LVORM,
        VERSG,
        BONUS,
        PROVG,
        SKTOF,
        VMSTA,
        VMSTD,
        AUMNG,
        LFMNG,
        EFMNG,
        SCMNG,
        SCHME,
        VRKME,
        MTPOS,
        DWERK,
        PRODH,
        PMATN,
        KONDM,
        KTGRM,
        MVGR1,
        MVGR2,
        MVGR3,
        MVGR4,
        MVGR5,
        SSTUF,
        PFLKS,
        LSTFL,
        LSTVZ,
        LSTAK,
        LDVFL,
        LDBFL,
        LDVZL,
        LDBZL,
        VDVFL,
        VDBFL,
        VDVZL,
        VDBZL,
        PRAT1,
        PRAT2,
        PRAT3,
        PRAT4,
        PRAT5,
        PRAT6,
        PRAT7,
        PRAT8,
        PRAT9,
        PRATA,
        RDPRF,
        MEGRU,
        LFMAX,
        RJART,
        PBIND,
        VAVME,
        MATKC,
        PVMSO,
        DUMMY_SALD_INCL_EEW_PS,
        BEV1_EMLGRP,
        BEV1_EMDRCKSPL,
        BEV1_RPBEZME,
        BEV1_RPSNS,
        BEV1_RPSFA,
        BEV1_RPSKI,
        BEV1_RPSCO,
        BEV1_RPSSO,
        NF_FLAG,
        PLGTP,
        ZZORITN,
        ZZRFRC,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU019_MVKE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data