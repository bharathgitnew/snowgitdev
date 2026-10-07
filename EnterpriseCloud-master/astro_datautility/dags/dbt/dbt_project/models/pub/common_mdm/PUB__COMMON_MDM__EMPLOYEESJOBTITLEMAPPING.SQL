/************
Model file generated from dbtGeneratePubViews: 04.05.2022.12.11.11"
*************/

{{ config(
      materialized='view',
      alias='EMPLOYEESJOBTITLEMAPPING',
      transient=false
) }}

with source_data as (
    SELECT
        TEA_COMMON_JOB_TITLE,
        JOB_TITLE_GROUP,
        MANAGER_FLAG,
        JOB_CATEGORY,
        FE_GROUP
    from {{ ref('COMMON__MDM__EMPLOYEESJOBTITLEMAPPING') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data