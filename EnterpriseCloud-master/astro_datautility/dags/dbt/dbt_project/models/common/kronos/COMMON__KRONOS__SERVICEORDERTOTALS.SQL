{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='ServiceOrderTotals'
) }}


with SourceData as (
SELECT
QRY_ServiceOrderTotals.FIRSTTIMESHEETENTRY,
QRY_ServiceOrderTotals.LASTTIMESHEETENTRY,
QRY_ServiceOrderTotals.SERVICEORDER,
QRY_ServiceOrderTotals.TOTALHOURSWORKED,
QRY_ServiceOrderTotals.TOTALHOURSWORKEDLAST30DAYS
FROM
(
SELECT ServiceOrder,
  MIN(EventDate) AS FirstTimesheetEntry,
  SUM(HoursCharged) AS TotalHoursWorked,
  MAX(EventDate) AS LastTimesheetEntry,
  SUM(CASE WHEN EventDate BETWEEN DATEADD(Day, -30, CURRENT_DATE) AND CURRENT_DATE THEN HoursCharged
     ELSE 0 END) AS TotalHoursWorkedLast30Days
  FROM {{ ref('COMMON__KRONOS__TIMESHEET') }}
   WHERE EventDate >= '2014-04-01'
AND  ((SourceSystem = 'O' and EVENTDATE < '2021-09-04')
OR  (SourceSystem IN ('N','C') and  EVENTDATE >= '2021-09-04'))
GROUP BY ServiceOrder
) QRY_ServiceOrderTotals
)

,transform_data as (
   select 
      FIRSTTIMESHEETENTRY,
      LASTTIMESHEETENTRY,
      SERVICEORDER,
      TOTALHOURSWORKED,
      TOTALHOURSWORKEDLAST30DAYS,
      '{{ invocation_id }}' AS AUDIT_LOG_ID
  from SourceData
)


,type_data as (
    SELECT
        CAST(FIRSTTIMESHEETENTRY AS TIMESTAMP_LTZ(9)) AS FIRSTTIMESHEETENTRY,
        CAST(LASTTIMESHEETENTRY AS TIMESTAMP_LTZ(9)) AS LASTTIMESHEETENTRY,
        CAST(SERVICEORDER AS VARCHAR(16777216)) AS SERVICEORDER,
        CAST(TOTALHOURSWORKED AS NUMBER(38,12)) AS TOTALHOURSWORKED,
        CAST(TOTALHOURSWORKEDLAST30DAYS AS NUMBER(38,12)) AS TOTALHOURSWORKEDLAST30DAYS,
        CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID
    FROM transform_data
)

SELECT * from type_data