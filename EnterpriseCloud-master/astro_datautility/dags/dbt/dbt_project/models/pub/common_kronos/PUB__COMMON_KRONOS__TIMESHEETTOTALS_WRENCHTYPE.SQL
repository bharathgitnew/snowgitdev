/************
Model file generated from dbtGeneratePubViews: 02.03.2023.17.18.24"
*************/

{{ config(
      materialized='view',
      alias='TIMESHEETTOTALS_WRENCHTYPE',
      transient=false
) }}

with source_data as (
    SELECT
        TIMESHEETITEMID,
        MEETING,
        NO_CODE,
        ON_CALL,
        PAPERWORK,
        PROJECTS,
        TIME_OFF,
        TRAINING,
        TRAVEL,
        WAITING,
        WRENCH_TIME,
        TOTALHOURS
    from {{ ref('COMMON__KRONOS__TIMESHEETTOTALS_WRENCHTYPE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data