/************
Model file generated from dbtGeneratePubViews: 04.08.2022.10.57.00"
*************/

{{ config(
      materialized='view',
      alias='OBJECTSONCONTRACTS',
      transient=false
) }}

with source_data as (
    SELECT
        CONTRACT_NO,
        CONFIGURATION,
        OBJECT,
        OBJECT_NUMBER,
        SERIAL_NUMBER,
        SERVICE_TYPE,
        COST_TYPE,
        CONVERAGE_TERM_NUMBER,
        TEL_BU,
        TEA_BU,
        DIMENSION_CODE,
        DIMENSION_DESCRIPTION,
        SYSTEM_STATUS_CODE,
        SYSTEM_STATUS,
        CONTRACT_STATUS_CODE,
        CONTRACT_STATUS,
        CONTRACT_DESC
    from {{ ref('COMMON__BAAN__OBJECTSONCONTRACTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data