/************
Model file generated from dbtGeneratePubViews: 03.13.2023.10.56.29"
*************/

{{ config(
      materialized='view',
      alias='SAP_AAM_EV_T093T_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        SPRAS,
        AFAPL,
        AFABER,
        AFBKTX,
        AFBTXT,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_AAM_EV_T093T_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data