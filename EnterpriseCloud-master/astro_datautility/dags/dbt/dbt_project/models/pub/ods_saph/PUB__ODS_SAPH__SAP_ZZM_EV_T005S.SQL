/************
Model file generated from dbtGeneratePubViews: 02.23.2023.08.45.20"
*************/

{{ config(
      materialized='view',
      alias='SAP_ZZM_EV_T005S',
      transient=false
) }}

with source_data as (
    SELECT
        LAND1,
        BLAND,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        XF_REGIONGRPCODE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_ZZM_EV_T005S') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data