/************
Model file generated from dbtGeneratePubViews: 08.12.2022.15.01.26"
*************/

{{ config(
      materialized='view',
      alias='SAP_US_SDT_EV_VBEP',
      enabled=false,
      transient=false
) }}

with source_data as (
    SELECT
        VBELN,
        POSNR,
        ETENR,
        ETTYP,
        LFREL,
        EDATU,
        EZEIT,
        WMENG,
        VRKME,
        BMENG,
        VRKME001,
        VRKME002,
        LMENG,
        MEINS,
        MEINS001,
        BDDAT,
        BDART,
        PLART,
        VBELE,
        POSNE,
        ETENE,
        RSDAT,
        IDNNR,
        BANFN,
        BSART,
        BSTYP,
        WEPOS,
        REPOS,
        LRGDT,
        PRGRS,
        TDDAT,
        MBDAT,
        LDDAT,
        WADAT,
        CMENG,
        VRKME003,
        LIFSP,
        GRSTR,
        ABART,
        ABRUF,
        ROMS1,
        VRKME004,
        ROMS2,
        ROMEI,
        ROMS3,
        ROMEI001,
        ROMEI002,
        RFORM,
        UMVKZ,
        UMVKN,
        VERFP,
        BWART,
        BNFPO,
        ETART,
        AUFNR,
        PLNUM,
        SERNR,
        AESKD,
        ABGES,
        MBUHR,
        TDUHR,
        LDUHR,
        WAUHR,
        AULWE,
        HANDOVERDATE,
        HANDOVERTIME,
        MBDAT_DRS,
        DLVQTY_SU,
        VRKME005,
        ZZUPDDTMS,
        VKORG,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_US_SDT_EV_VBEP') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data