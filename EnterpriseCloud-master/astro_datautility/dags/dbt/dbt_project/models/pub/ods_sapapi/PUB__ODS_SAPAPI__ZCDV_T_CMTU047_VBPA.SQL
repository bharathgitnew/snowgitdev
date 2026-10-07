/************
Model file generated from dbtGeneratePubViews: 11.03.2022.06.08.38"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU047_VBPA',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
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
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU047_VBPA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data