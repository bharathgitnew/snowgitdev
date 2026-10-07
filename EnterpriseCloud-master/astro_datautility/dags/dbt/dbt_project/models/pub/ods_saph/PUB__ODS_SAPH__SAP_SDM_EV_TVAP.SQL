/************
Model file generated from dbtGeneratePubViews: 03.02.2023.08.55.54"
*************/

{{ config(
      materialized='view',
      alias='SAP_SDM_EV_TVAP',
      transient=false
) }}

with source_data as (
    SELECT
        PSTYV,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_SDM_EV_TVAP') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data