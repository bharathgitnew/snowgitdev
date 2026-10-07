/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.25"
*************/

{{ config(
      materialized='view',
      alias='MANAGERSERVICEGROUP',
      transient=false
) }}

with source_data as (
    SELECT
        MANAGER,
        EMPID,
        EMPGROUP,
        JOBTITLEGROUP,
        JOBCATEGORY,
        OFFICENAME,
        LASTAUDITDATE,
        REGIONALSERVICEMANAGER,
        SERVICEMANAGERID,
        ACTIVE
    from {{ ref('ODS__MDM__MANAGERSERVICEGROUP') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data