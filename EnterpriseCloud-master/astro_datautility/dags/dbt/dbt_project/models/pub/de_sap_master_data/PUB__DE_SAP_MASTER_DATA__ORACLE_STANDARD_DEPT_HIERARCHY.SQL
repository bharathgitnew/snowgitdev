{{ config(
      materialized='view',
      alias='ORACLE_STANDARD_DEPT_HIERARCHY',
      transient=false
) }}

with source_data as (
    SELECT
        ORACLE_PARENT,
        ORACLE_PARENT_ALIAS,
        ORACLE_DEPARTMENT,
        ORACLE_DEPARTMENT_ALIAS
    from {{ ref('COMMON__SAPH__ORACLE_STANDARD_DEPT_HIERARCHY') }}
),

transform_data AS (
    select * from source_data
)

    select * from transform_data