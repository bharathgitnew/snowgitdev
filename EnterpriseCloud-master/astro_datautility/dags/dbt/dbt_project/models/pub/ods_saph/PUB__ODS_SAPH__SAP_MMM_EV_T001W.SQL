/************
Model file generated from dbtGeneratePubViews: 02.21.2023.08.06.39"
*************/

{{ config(
      materialized='view',
      alias='SAP_MMM_EV_T001W',
      transient=false
) }}

with source_data as (
    SELECT
        WERKS,
        NAME1,
        BWKEY,
        FABKL,
        LAND1,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_MMM_EV_T001W') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data