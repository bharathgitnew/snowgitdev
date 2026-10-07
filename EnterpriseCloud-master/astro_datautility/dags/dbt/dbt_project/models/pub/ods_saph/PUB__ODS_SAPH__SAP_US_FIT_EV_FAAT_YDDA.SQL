/************
Model file generated from dbtGeneratePubViews: 09.29.2022.10.34.53"
*************/

{{ config(
      materialized='view',
      alias='SAP_US_FIT_EV_FAAT_YDDA',
      transient=false
) }}

with source_data as (
    SELECT
        BUKRS,
        ANLN1,
        ANLN2,
        GJAHR,
        AFABE,
        XAFAR,
        NDABJ,
        NDABP,
        ANDSJ,
        ANDSP,
        RSTCK,
        MIG_SOURCE,
        PERFY_IN_FY,
        NDABP_IN_FY,
        ANDSP_IN_FY,
        UNITS_IN_FY,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_US_FIT_EV_FAAT_YDDA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data