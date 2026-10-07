/************
Model file generated from dbtGeneratePubViews: 03.09.2022.17.41.10"
*************/

{{ config(
      materialized='view',
      alias='LASTBACKUP',
      transient=false
) }}

with source_data as (
    SELECT
        CLUSTERNAME,
        INSTANCENAME,
        DATABASENAME,
        STARTDATE,
        FINISHDATE,
        SIZE,
        BACKUPTYPE,
        ISNATIVEBACKUP,
        BACKUPDEVICE
    from {{ ref('ODS__REDGATE__LASTBACKUP') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data