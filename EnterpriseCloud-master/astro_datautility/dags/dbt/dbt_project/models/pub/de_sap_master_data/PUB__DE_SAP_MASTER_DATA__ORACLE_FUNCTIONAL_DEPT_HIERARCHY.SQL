{{ config(
      materialized='view',
      alias='ORACLE_FUNCTIONAL_DEPT_HIERARCHY',
      transient=false
) }}

with source_data as (
    SELECT
        FUNCTIONAL_DEPARTMENT,
        DEPARTMENT,
        DEPARTMENT_ALIAS
    from {{ ref('COMMON__SAPH__ORACLE_FUNCTIONAL_DEPT_HIERARCHY') }}
),

transform_data AS (
    select * from source_data
)

    select * from transform_data