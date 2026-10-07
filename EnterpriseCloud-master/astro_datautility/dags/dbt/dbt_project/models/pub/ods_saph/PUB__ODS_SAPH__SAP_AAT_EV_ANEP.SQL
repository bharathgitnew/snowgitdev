/************
Model file generated from dbtGeneratePubViews: 03.13.2023.10.56.29"
*************/

{{ config(
      materialized='view',
      alias='SAP_AAT_EV_ANEP',
      transient=false
) }}

with source_data as (
    SELECT
        BUKRS,
        ANLN1,
        ANLN2,
        GJAHR,
        LNRAN,
        AFABE,
        ZUJHR,
        ZUCOD,
        PERAF,
        BELNR,
        BUZEI,
        BZDAT,
        BWASL,
        XAFAR,
        ANBTR,
        WAERS,
        NAFAB,
        WAERS001,
        SAFAB,
        WAERS002,
        ZINSB,
        WAERS003,
        XANTW,
        XAWBT,
        LNSAN,
        ANUPD,
        AUGLN,
        UPDDT,
        AEDAT,
        CPUDT,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_AAT_EV_ANEP') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data