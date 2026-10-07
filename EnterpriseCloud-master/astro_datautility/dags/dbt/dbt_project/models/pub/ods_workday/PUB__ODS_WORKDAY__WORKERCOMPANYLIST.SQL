/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.41.52"
*************/

{{ config(
      materialized='view',
      alias='WORKERCOMPANYLIST',
      transient=false
) }}

with source_data as (
    SELECT
        EMPLOYEEID,
        HOMECOMPANYID,
        HOMEDEPARTMENTID,
        HOSTCOMPANYID,
        HOSTDEPARTMENTID
    from {{ ref('ODS__WORKDAY__WORKERCOMPANYLIST') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data