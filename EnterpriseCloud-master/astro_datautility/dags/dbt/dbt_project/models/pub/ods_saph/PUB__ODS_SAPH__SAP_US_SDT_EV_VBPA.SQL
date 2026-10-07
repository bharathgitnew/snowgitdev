/************
Model file generated from dbtGeneratePubViews: 10.11.2022.08.55.32"
*************/

{{ config(
      materialized='view',
      alias='SAP_US_SDT_EV_VBPA',
      transient=false
) }}

with source_data as (
    SELECT
        VBELN,
        POSNR,
        PARVW,
        KUNNR,
        LIFNR,
        PERNR,
        PARNR,
        ADRNR,
        ABLAD,
        LAND1,
        ADRDA,
        XCPDK,
        HITYP,
        PRFRE,
        BOKRE,
        HISTUNR,
        KNREF,
        LZONE,
        HZUOR,
        STCEG,
        PARVW_FF,
        ADRNP,
        KALE,
        _DATAAGING,
        DUMMY_SDDOCPARTNER_INCL_EEW_PS,
        ERDAT,
        AEDAT,
        VKORG,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_US_SDT_EV_VBPA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data