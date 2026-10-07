/************
Model file generated from dbtGeneratePubViews: 03.02.2023.08.55.49"
*************/

{{ config(
      materialized='view',
      alias='SAP_ZZM_EV_T005U',
      transient=false
) }}

with source_data as (
    SELECT
        SPRAS,
        LAND1,
        BLAND,
        BEZEI,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_ZZM_EV_T005U') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data