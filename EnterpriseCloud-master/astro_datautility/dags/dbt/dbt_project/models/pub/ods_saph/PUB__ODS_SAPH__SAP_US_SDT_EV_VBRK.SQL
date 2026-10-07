/************
Model file generated from dbtGeneratePubViews: 09.22.2022.06.42.38"
*************/

{{ config(
      materialized='view',
      alias='SAP_US_SDT_EV_VBRK',
      transient=false
) }}

with source_data as (
    SELECT
        VBELN,
        FKART,
        FKTYP,
        VBTYP,
        WAERK,
        VKORG,
        VTWEG,
        KALSM,
        KNUMV,
        VSBED,
        FKDAT,
        BELNR,
        GJAHR,
        POPER,
        KONDA,
        KDGRP,
        BZIRK,
        PLTYP,
        INCO1,
        INCO2,
        RFBSK,
        MRNKZ,
        KURRF,
        CPKUR,
        VALTG,
        VALDT,
        ZTERM,
        ZLSCH,
        LAND1,
        REGIO,
        COUNC,
        CITYC,
        BUKRS,
        TAXK1,
        TAXK2,
        TAXK3,
        TAXK4,
        TAXK5,
        TAXK6,
        TAXK7,
        TAXK8,
        TAXK9,
        NETWR,
        ERNAM,
        ERZET,
        ERDAT,
        KUNRG,
        KUNAG,
        MABER,
        STCEG,
        AEDAT,
        SFAKN,
        KNUMA,
        FKART_RL,
        FKDAT_RL,
        KURST,
        MSCHL,
        MANSP,
        KKBER,
        KNKLI,
        CMWAE,
        BSTNK_VF,
        VBUND,
        STCEG_H,
        STCEG_L,
        XBLNR,
        ZUONR,
        MWSBK,
        FKSTO,
        XEGDR,
        INTRA_REL,
        INTRA_EXCL,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_US_SDT_EV_VBRK') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data