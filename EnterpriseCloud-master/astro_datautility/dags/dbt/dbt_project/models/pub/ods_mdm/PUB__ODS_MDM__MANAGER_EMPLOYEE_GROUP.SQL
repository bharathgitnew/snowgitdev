/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.25"
*************/

{{ config(
      materialized='view',
      alias='MANAGER_EMPLOYEE_GROUP',
      transient=false
) }}

with source_data as (
    SELECT
        SUPERVISORID,
        GROUPNAME
    from {{ ref('ODS__MDM__MANAGER_EMPLOYEE_GROUP') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data