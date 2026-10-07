/************
Model file generated from dbtGeneratePubViews: 03.02.2023.08.56.00"
*************/

{{ config(
      materialized='view',
      alias='SAP_SDM_EV_T685T_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        SPRAS,
        KVEWE,
        KAPPL,
        KSCHL,
        VTEXT,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_SDM_EV_T685T_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data