/************
Model file generated from dbtGeneratePubViews: 02.23.2023.08.45.15"
*************/

{{ config(
      materialized='view',
      alias='SAP_ZZM_EV_T005T',
      transient=false
) }}

with source_data as (
    SELECT
        SPRAS,
        LAND1,
        LANDX,
        NATIO,
        LANDX50,
        NATIO50,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_ZZM_EV_T005T') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data