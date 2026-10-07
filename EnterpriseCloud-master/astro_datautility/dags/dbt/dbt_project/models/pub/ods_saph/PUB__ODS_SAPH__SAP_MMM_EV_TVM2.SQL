/************
Model file generated from dbtGeneratePubViews: 03.02.2023.08.55.47"
*************/

{{ config(
      materialized='view',
      alias='SAP_MMM_EV_TVM2',
      transient=false
) }}

with source_data as (
    SELECT
        MVGR2,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_MMM_EV_TVM2') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data