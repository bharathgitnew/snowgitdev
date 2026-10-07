/************
Model file generated from dbtGeneratePubViews: 02.23.2023.08.45.31"
*************/

{{ config(
      materialized='view',
      alias='SAP_ZZM_EV_T005',
      transient=false
) }}

with source_data as (
    SELECT
        LAND1,
        SPRAS,
        INTCA,
        INTCA3,
        INTCN3,
        WAERS,
        KALSM,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        XF_COUNTRYGRPCODE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_ZZM_EV_T005') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data