/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.20"
*************/

{{ config(
      materialized='view',
      alias='EMPLOYEE_GROUP_MAPPING',
      transient=false
) }}

with source_data as (
    SELECT
        FST_EMP_GROUP,
        REGIONAL_SERVICE_MANAGER,
        SERVICE_MANAGER_ID,
        REGIONAL_SALES_MANAGER,
        SALES_MANAGER_ID
    from {{ ref('ODS__MDM__EMPLOYEE_GROUP_MAPPING') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data