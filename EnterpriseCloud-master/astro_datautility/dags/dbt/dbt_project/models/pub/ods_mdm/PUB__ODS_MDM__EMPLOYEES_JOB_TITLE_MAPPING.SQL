/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.20"
*************/

{{ config(
      materialized='view',
      alias='EMPLOYEES_JOB_TITLE_MAPPING',
      transient=false
) }}

with source_data as (
    SELECT
        TEA_COMMON_JOB_TITLE,
        JOB_TITLE_GROUP,
        MANAGER_FLAG,
        JOB_CATEGORY,
        FE_GROUP
    from {{ ref('ODS__MDM__EMPLOYEES_JOB_TITLE_MAPPING') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data