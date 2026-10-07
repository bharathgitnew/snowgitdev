/************
Model file generated from dbtGeneratePubViews: 03.13.2023.10.56.47"
*************/

{{ config(
      materialized='view',
      alias='SAP_MMM_EV_T163K',
      transient=false
) }}

with source_data as (
    SELECT
        KNTTP,
        KZVBR,
        KNTAE,
        REUPD,
        WEPOS,
        WEPOV,
        WEUNB,
        WEUNV,
        REPOS,
        REPOV,
        KOMOK,
        KNTDY,
        SOBKZ,
        KONAB,
        TAXIK,
        XBNSB,
        VRTKZ,
        TWRKZ,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_MMM_EV_T163K') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data