/************
Model file generated from dbtGeneratePubViews: 03.02.2023.08.55.59"
*************/

{{ config(
      materialized='view',
      alias='SAP_MMM_EV_MLAN_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        MATNR,
        ALAND,
        TAXM1,
        TAXM2,
        TAXM3,
        TAXM4,
        TAXM5,
        TAXM6,
        TAXM7,
        TAXM8,
        TAXM9,
        TAXIM,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_MMM_EV_MLAN_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data