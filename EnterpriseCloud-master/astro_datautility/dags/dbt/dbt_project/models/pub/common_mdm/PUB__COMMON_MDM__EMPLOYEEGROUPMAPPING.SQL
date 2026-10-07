/************
Model file generated from dbtGeneratePubViews: 04.05.2022.12.11.10"
*************/

{{ config(
      materialized='view',
      alias='EMPLOYEEGROUPMAPPING',
      transient=false
) }}

with source_data as (
    SELECT
        FST_EMP_GROUP,
        REGIONAL_SERVICE_MANAGER,
        SERVICE_MANAGER_ID,
        REGIONAL_SALES_MANAGER,
        SALES_MANAGER_ID
    from {{ ref('COMMON__MDM__EMPLOYEEGROUPMAPPING') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data