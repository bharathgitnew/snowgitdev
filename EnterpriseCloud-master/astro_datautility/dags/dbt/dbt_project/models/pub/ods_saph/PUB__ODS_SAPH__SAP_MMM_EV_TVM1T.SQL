/************
Model file generated from dbtGeneratePubViews: 03.02.2023.08.55.55"
*************/

{{ config(
      materialized='view',
      alias='SAP_MMM_EV_TVM1T',
      transient=false
) }}

with source_data as (
    SELECT
        SPRAS,
        MVGR1,
        BEZEI,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_MMM_EV_TVM1T') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data