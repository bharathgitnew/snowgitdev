/************
Model file generated from dbtGeneratePubViews: 10.11.2022.08.55.29"
*************/

{{ config(
      materialized='view',
      alias='SAP_SDM_EV_KNVV',
      transient=false
) }}

with source_data as (
    SELECT
        KUNNR,
        VKORG,
        VTWEG,
        SPART,
        ERNAM,
        ERDAT,
        LOEVM,
        VERSG,
        AUFSD,
        KDGRP,
        BZIRK,
        KLABC,
        KTGRD,
        VWERK,
        VKGRP,
        VKBUR,
        KVGR1,
        KVGR2,
        KVGR3,
        KVGR4,
        KVGR5,
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
        WAERS,
        KURST,
        KONDA,
        KALKS,
        LPRIO,
        VSBED,
        AUTLF,
        INCO1,
        INCO2_L,
        INCO3_L,
        ZTERM,
        KKBER,
        CASSD,
        ZZSPRMC,
        ZZEDIASOC,
        ZZEBIZC,
        ZZCNFRL,
        ZZDWC,
        ZZAAC,
        ZZFSAREA,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_SDM_EV_KNVV') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data