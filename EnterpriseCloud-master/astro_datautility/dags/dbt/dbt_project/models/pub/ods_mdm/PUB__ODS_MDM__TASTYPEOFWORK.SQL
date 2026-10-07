/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.32"
*************/

{{ config(
      materialized='view',
      alias='TASTYPEOFWORK',
      transient=false
) }}

with source_data as (
    SELECT
        TYPE_OF_WORK,
        TAS_TYPE_OF_WORK,
        TAS_TYPE_OF_WORK_GROUP,
        SOURCE,
        SERVICE_UTILIZATION_GROUP,
        SO_EXPECTED_IN_CRM,
        REVENUE_SOURCE,
        EXPECTED_SO_SERIES,
        LEGACY_TYPE_OF_WORK,
        SERVICE_COSTING_PRODUCT_TYPE_CODE,
        BILLABLE_CATEGORY_GROUP
    from {{ ref('ODS__MDM__TASTYPEOFWORK') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data