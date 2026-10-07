/************
Model file generated from dbtGeneratePubViews: 02.20.2023.06.07.08"
*************/

{{ config(
      materialized='view',
      alias='SAP_MMM_EV_EINE',
      transient=false,
	  enabled=false
) }}

with source_data as (
    SELECT
        INFNR,
        EKORG,
        ESOKZ,
        WERKS,
        LOEKZ,
        ERDAT,
        ERDAT001,
        ERNAM,
        EKGRP,
        WAERS,
        BONUS,
        MGBON,
        MINBM,
        MEINS,
        NORBM,
        MEINS001,
        APLFZ,
        UEBTO,
        UEBTK,
        UNTTO,
        ANGNR,
        ANGDT,
        ANFNR,
        ANFPS,
        ABSKZ,
        BSTYP,
        EBELN,
        EBELP,
        DATLB,
        NETPR,
        WAERS001,
        PEINH,
        BPRME,
        PRDAT,
        BPUMZ,
        BPUMN,
        MTXNO,
        WEBRE,
        EFFPR,
        WAERS002,
        EKKOL,
        SKTOF,
        KZABS,
        MWSKZ,
        BWTAR,
        EBONU,
        EVERS,
        EXPRF,
        BSTAE,
        MEPRF,
        INCO1,
        INCO2,
        XERSN,
        EBON2,
        EBON3,
        EBONF,
        MHDRZ,
        VERID,
        BSTMA,
        MEINS002,
        RDPRF,
        MEGRU,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_MMM_EV_EINE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data