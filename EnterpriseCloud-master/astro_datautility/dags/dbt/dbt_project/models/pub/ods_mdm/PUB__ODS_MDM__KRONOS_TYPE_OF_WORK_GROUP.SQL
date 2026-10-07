/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.23"
*************/

{{ config(
      materialized='view',
      alias='KRONOS_TYPE_OF_WORK_GROUP',
      transient=false
) }}

with source_data as (
    SELECT
        TYPE_OF_WORK,
        TYPE_OF_WORK_GROUP,
        BILLABLE_CATEGORY,
        GENERAL_CATEGORY,
        LABOR_TYPE,
        PRODUCT_TYPE_CODE,
        REVENUE_PER_TOOL_CATEGORY,
        PRODUCT_SUB_CATEGORY,
        KPI_TYPE_OF_WORK,
        REVENUE_SOURCE
    from {{ ref('ODS__MDM__KRONOS_TYPE_OF_WORK_GROUP') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data