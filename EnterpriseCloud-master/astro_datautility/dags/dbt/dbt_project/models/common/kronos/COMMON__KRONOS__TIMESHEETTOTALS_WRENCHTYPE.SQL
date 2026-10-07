{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='TimesheetTotals_WrenchType',
    unique_key = ['TimesheetItemId']
) }}


with souredata_1 as (
SELECT
QRY_TimesheetTotals_WrenchTime.TIMESHEETITEMID AS TimesheetItemId,
IFNULL ( QRY_TimesheetTotals_WrenchTime.MEETING , 0 ) AS Meeting,
IFNULL ( QRY_TimesheetTotals_WrenchTime.NO_CODE , 0 ) AS No_Code,
IFNULL ( QRY_TimesheetTotals_WrenchTime.ON_CALL , 0 ) AS On_Call,
IFNULL ( QRY_TimesheetTotals_WrenchTime.PAPERWORK , 0 ) AS Paperwork,
IFNULL ( QRY_TimesheetTotals_WrenchTime.PROJECTS , 0 ) AS Projects,
IFNULL ( QRY_TimesheetTotals_WrenchTime.TIME_OFF , 0 ) AS Time_Off,
IFNULL ( QRY_TimesheetTotals_WrenchTime.TRAINING , 0 ) AS Training,
IFNULL ( QRY_TimesheetTotals_WrenchTime.TRAVEL , 0 ) AS Travel,
IFNULL ( QRY_TimesheetTotals_WrenchTime.WAITING , 0 ) AS Waiting,
IFNULL ( QRY_TimesheetTotals_WrenchTime.WRENCH_TIME , 0 ) AS Wrench_Time,
IFNULL ( QRY_TimesheetTotals_WrenchTime.MEETING , 0 ) + IFNULL ( QRY_TimesheetTotals_WrenchTime.NO_CODE , 0 ) + IFNULL ( QRY_TimesheetTotals_WrenchTime.ON_CALL , 0 ) + IFNULL ( QRY_TimesheetTotals_WrenchTime.PROJECTS , 0 ) + IFNULL ( QRY_TimesheetTotals_WrenchTime.TIME_OFF , 0 ) + IFNULL ( QRY_TimesheetTotals_WrenchTime.TRAINING , 0 ) + IFNULL ( QRY_TimesheetTotals_WrenchTime.TRAVEL , 0 ) + IFNULL ( QRY_TimesheetTotals_WrenchTime.WAITING , 0 ) + IFNULL ( QRY_TimesheetTotals_WrenchTime.WRENCH_TIME , 0 ) AS TotalHours,
0 AS ERROR_FLAG,
CAST('' AS VARCHAR(200)) AS ERROR_REASON,
CAST('' AS VARCHAR(100)) AS ERROR_CODE,
CAST(LOCALTIMESTAMP AS TIMESTAMP) AS RECORD_INSERT_TIMESTAMP,
CAST('INSERT' AS VARCHAR(100)) AS OPERATION_TYPE,
ROW_NUMBER() OVER (ORDER BY 1) AS SRC_ROW_NUMBER
FROM
(
WITH souredata_2 AS
(
    SELECT TimesheetItemId,TaskWrenchType,HoursCharged
    FROM {{ ref('COMMON__KRONOS__TIMESHEET') }}
)
SELECT 
  TimesheetItemId,Meeting,No_Code,On_Call,Paperwork,Projects,Time_Off,Training,Travel,Waiting,Wrench_Time  
FROM souredata_2
PIVOT (
    SUM(HOURSCHARGED) FOR TASKWRENCHTYPE IN ('Meeting','No Code','On Call','Paperwork','Projects','Time Off','Training','Travel','Waiting','Wrench Time')
) AS PivotTable (TimesheetItemId,Meeting,No_Code,On_Call,Paperwork,Projects,Time_Off,Training,Travel,Waiting,Wrench_Time)
) QRY_TimesheetTotals_WrenchTime

)

,transform_data as (
  select 
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
  TOTALHOURS,
  ERROR_FLAG,
  ERROR_REASON,
  ERROR_CODE,
  RECORD_INSERT_TIMESTAMP,
  OPERATION_TYPE,
  SRC_ROW_NUMBER,
	'{{ invocation_id }}' AS AUDIT_LOG_ID,
	SHA2('hash_me') AS _ROW_HASH 
	FROM souredata_1
)

,type_data as (
    SELECT
        CAST(TIMESHEETITEMID AS VARCHAR(16777216)) AS TIMESHEETITEMID,
        CAST(MEETING AS NUMBER(38,12)) AS MEETING,
        CAST(NO_CODE AS NUMBER(38,12)) AS NO_CODE,
        CAST(ON_CALL AS NUMBER(38,12)) AS ON_CALL,
        CAST(PAPERWORK AS NUMBER(38,12)) AS PAPERWORK,
        CAST(PROJECTS AS NUMBER(38,12)) AS PROJECTS,
        CAST(TIME_OFF AS NUMBER(38,12)) AS TIME_OFF,
        CAST(TRAINING AS NUMBER(38,12)) AS TRAINING,
        CAST(TRAVEL AS NUMBER(38,12)) AS TRAVEL,
        CAST(WAITING AS NUMBER(38,12)) AS WAITING,
        CAST(WRENCH_TIME AS NUMBER(38,12)) AS WRENCH_TIME,
        CAST(TOTALHOURS AS NUMBER(38,12)) AS TOTALHOURS,
        CAST(ERROR_FLAG AS NUMBER(1,0)) AS ERROR_FLAG,
        CAST(ERROR_REASON AS VARCHAR(200)) AS ERROR_REASON,
        CAST(ERROR_CODE AS VARCHAR(100)) AS ERROR_CODE,
        CAST(RECORD_INSERT_TIMESTAMP AS TIMESTAMP_NTZ(9)) AS RECORD_INSERT_TIMESTAMP,
        CAST(OPERATION_TYPE AS VARCHAR(100)) AS OPERATION_TYPE,
        CAST(SRC_ROW_NUMBER AS NUMBER(18,0)) AS SRC_ROW_NUMBER,
        CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
    FROM transform_data
)

SELECT * from type_data