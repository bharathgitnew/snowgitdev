/************
Model file generated from dbtGeneratePubViews: 03.02.2023.08.55.51"
*************/

{{ config(
      materialized='view',
      alias='SAP_FIM_EV_T001',
      transient=false
) }}

with source_data as (
    SELECT
        BUKRS,
        BUTXT,
        LAND1,
        WAERS,
        SPRAS,
        KTOPL,
        PERIV,
        KKBER,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_FIM_EV_T001') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data