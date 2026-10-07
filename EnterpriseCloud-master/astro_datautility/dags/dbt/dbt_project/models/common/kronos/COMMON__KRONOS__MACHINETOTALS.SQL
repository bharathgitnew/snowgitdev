{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='MachineTotals'
) }}


with SourceData as (
SELECT
QRY_Timesheet_MachineTotals.CONCESSION,
QRY_Timesheet_MachineTotals.ERROR,
QRY_Timesheet_MachineTotals.FCN_HOURS,
QRY_Timesheet_MachineTotals.MACHINE_SERIAL_NUMBER,
QRY_Timesheet_MachineTotals.MODIFICATION,
QRY_Timesheet_MachineTotals.PAID_SERVICE_HOURS,
QRY_Timesheet_MachineTotals.PRE_STARTUP_HOURS,
QRY_Timesheet_MachineTotals.PRE_WARRANTY_HOURS,
QRY_Timesheet_MachineTotals.SERVICE_CONTRACT_HOURS,
QRY_Timesheet_MachineTotals.STARTUP_HOURS,
QRY_Timesheet_MachineTotals.TECHNICAL_SUPPORT,
QRY_Timesheet_MachineTotals.TRAINING,
QRY_Timesheet_MachineTotals.TSC_SERVICE,
QRY_Timesheet_MachineTotals.USED_EQUIPMENT,
QRY_Timesheet_MachineTotals.WARRANTY_HOURS
FROM
(
--MachineTotals
SELECT
     Machine_Serial_Number,
     COALESCE("'Pre-Startup'", 0) AS Pre_Startup_Hours,
     COALESCE("'Startup'", 0) AS Startup_Hours,
     COALESCE("'Pre-Warranty'", 0) AS Pre_Warranty_Hours,
     COALESCE("'Warranty'", 0) AS Warranty_Hours,
     COALESCE("'FCN'", 0) AS FCN_Hours,
     COALESCE("'Paid Service'", 0) AS Paid_Service_Hours,
     COALESCE("'Service Contract'", 0) AS Service_Contract_Hours,
     COALESCE("'TSC Service'", 0) AS TSC_Service,
     COALESCE("'Used Equipment'", 0) AS Used_Equipment,
     COALESCE("'Modification'", 0) AS Modification,
     COALESCE("'Concession'", 0) AS Concession,
     COALESCE("'Technical Support'", 0) AS Technical_Support,
     COALESCE("'Training'", 0) AS Training,
     COALESCE("'Error'", 0) AS Error

FROM
(SELECT 
CASE 
  WHEN QRY_Timesheet.SOURCESYSTEM = 'O' AND QRY_Timesheet.PAYCODENAME = 'Hours Worked' THEN QRY_Timesheet.MACHINESN
  WHEN QRY_Timesheet.SOURCESYSTEM = 'C' THEN QRY_Timesheet.MACHINESN
  ELSE NULL 
END as Machine_Serial_Number,

ROUND(CASE 
  WHEN QRY_Timesheet.PAYCODENAME = 'On Call' THEN 0
  ELSE IFNULL(QRY_Timesheet.TIMEINSECONDS,0) / 3600 
END, 2) as Hours_Worked,

Kronos_WG.General_Category
FROM
(--QRY_Timesheet
  SELECT
     'O' AS SourceSystem
    ,CAST(CAST(TIMESHEETITEMID AS INT) AS VARCHAR(16777216)) TimesheetItemId
    ,ORGIDSID
    ,PERSONFULLNAME
    ,PERSONNUM
    ,HOME_LL1
    ,HOME_ADP_CO
    ,HOME_DIM1
    ,HOME_DIM2
    ,HOME_DIM3
    ,ENTEREDONDTM
    ,EVENTDATE
    ,STARTDTM
    ,ENDDTM
    ,TIMEINSECONDS
    ,PAYCODEID
    ,PAYCODENAME
    ,LABORLEVELNAME1
    ,ADPCOMPANY
    ,DIMENSION1
    ,DIMENSION2
    ,DIMENSION3
    ,LABORLEVELNAME2
    ,MACHINE_PROJECT
    ,LOCATION_OTHER
    ,LABORLEVELNAME3
    ,LABORLEVELNAME4
    ,LABORLEVELNAME5
    ,LABORLEVELNAME6
    ,LABORLEVELNAME7
    ,WORKRULENAME
    ,HOLIDAYID
    ,HOLIDAYNAME
    ,TMSHTITEMTYPEID
    ,TIMESHEETITEMTYPE
    ,HASCOMMENTSSW
    ,SCHEDWORKRULESW
    ,ORGID
    ,ORGNM
    ,ORGTYPEID
    ,ORGDSC
    ,ORGLEVELNBR
    ,REPORTTOORGID
    ,ORGPATHTXT
    ,EFFECTIVEDTM
    ,EXPIRATIONDTM
    ,Two
    ,Three
    ,Four
    ,Five
    ,Six
    ,Seven
    ,Eight
    ,TASK
    ,TYPEOFWORK
    ,MACHINESN
    ,FAB
    ,SO
    ,EMP_APPROVED
 --   ,SOLDTO_BPID
 --   ,FAB_OFFICE
    ,NULL COMMENTS
    ,NULL NOTES
    ,NULL TIMEPUNCHID
  FROM {{ source('ODS__KRONOS', 'TEA_RECENT_TIMESHEET') }}
  WHERE DeletedSW = 0
  UNION ALL
-- NEW TImecard Rows
  SELECT
     'N' AS SourceSystem
    ,recordid
    ,NULL AS OrgIDSid
    ,PersonFullName
    ,PersonNumber
    ,NULL AS HOme_LL1
    ,NULL AS HOME_ADP_CO
    ,NULL HOME_DIM1
    ,NULL HOME_DIM2
    ,NULL HOME_DIM3
    ,RecordCreatedDate --,NULL ENTEREDONDTM
    ,CAST(WorkedShiftEndDateTime AS DATETIME) EVENTDATE
    ,TimecardTransactionRoundedStartDateTime AS STARTDTM
    ,TimecardTransactionRoundedEndDateTime ENDDTM
    ,TimecardTransactionActualHoursWorked * 3600 AS TIMEINSECONDS
    ,PAYCODEID
    ,IFNULL(REPLACE(Timecard.PaycodeEditName,'US-',''),HolidayPaycode.Description) PAYCODENAME
    ,NULL LABORLEVELNAME1
    ,NULL ADPCOMPANY
    ,NULL DIMENSION1
    ,NULL DIMENSION2
    ,NULL DIMENSION3
    ,NULL LABORLEVELNAME2
    ,NULL MACHINE_PROJECT
    ,NULL LOCATION_OTHER
    ,NULL LABORLEVELNAME3
    ,NULL LABORLEVELNAME4
    ,NULL LABORLEVELNAME5
    ,NULL LABORLEVELNAME6
    ,NULL LABORLEVELNAME7
    ,WorkedShiftSegmentWorkrule WORKRULENAME
    ,CAST(NULL AS INT) HOLIDAYID
    ,TimecardTransactionApplyTo HOLIDAYNAME
    ,CAST(NULL AS INT) TMSHTITEMTYPEID
    ,TimecardTransactionType TIMESHEETITEMTYPE
    ,CAST(NULL AS NUMERIC(28,0)) HASCOMMENTSSW
    ,CAST(NULL AS NUMERIC(28,0)) SCHEDWORKRULESW
    ,CAST(NULL AS INT) ORGID
    ,NULL ORGNM
    ,CAST(NULL AS INT) ORGTYPEID
    ,NULL ORGDSC
    ,CAST(NULL AS INT) ORGLEVELNBR
    ,CAST(NULL AS NUMERIC(28,0)) REPORTTOORGID
    ,NULL ORGPATHTXT
    ,CAST(NULL AS DATETIME) EFFECTIVEDTM
    ,CAST(NULL AS DATETIME) EXPIRATIONDTM
    ,NULL Two
    ,NULL Three
    ,NULL Four
    ,NULL Five
    ,NULL Six
    ,NULL Seven
    ,NULL Eight
    ,NULL TASK
    ,'Time Off' TYPEOFWORK
    ,NULL MACHINESN
    ,NULL FAB
    ,NULL SO
    ,CAST(NULL AS INT) EMP_APPROVED
--    ,CAST(NULL AS CHAR) SOLDTO_BPID
--    ,CAST(NULL AS CHAR) FAB_OFFICE
    ,NULL COMMENTS
    ,WorkedShiftComments NOTES
    ,NULL TIMEPUNCHID
  FROM {{ ref('ODS__KRONOS__TIMECARD') }}
  LEFT OUTER JOIN {{ ref('ODS__MDM__TIMECARDPAYCODE') }} HolidayPaycode
  ON HolidayPaycode.Name = Timecard.TimecardTransactionApplyTo
  WHERE IFNULL(REPLACE(PaycodeEditName,'US-',''),Description) IS NOT NULL
  UNION ALL
-- ActivityTotalsRows

  SELECT
     'C' AS SourceSystem
    ,CAST(CAST(TransactionId AS INT) AS VARCHAR(16777216))
    ,NULL AS OrgIDSid
    ,NULL AS PersonFullName
    ,EmployeeNumber AS PersonNum
    ,HomeLaborCategory1CostStructure  AS HOME_LL1
    ,LEFT(HomeLaborCategory1CostStructure,3) AS Home_ADP_CO
    ,SUBSTRING(HomeLaborCategory1CostStructure, 5, 4)  HOME_DIM1
    ,SUBSTRING(HomeLaborCategory1CostStructure, 10, 4) HOME_DIM2
    ,SUBSTRING(HomeLaborCategory1CostStructure, 15, 4) HOME_DIM3
    ,CAST(NULL AS DATETIME) ENTEREDONDTM
    ,CAST(ApplyDate AS DATETIME) EVENTDATE
    ,AdjustedStartDateTime STARTDTM
    ,AdjustedEndDateTime ENDDTM
    ,SUM(AllocatedHoursTimeinSeconds * 3600) AS TIMEINSECONDS
    ,CAST(NULL AS INT) PAYCODEID
    ,PayCode PAYCODENAME
    ,HomeLaborCategory1CostStructure LABORLEVELNAME1
    ,SUBSTRING(HomeLaborCategory1CostStructure, 1, 3) ADPCOMPANY
    ,SUBSTRING(HomeLaborCategory1CostStructure, 5, 4) DIMENSION1
    ,SUBSTRING(HomeLaborCategory1CostStructure, 10, 4) DIMENSION2
    ,SUBSTRING(HomeLaborCategory1CostStructure, 15, 4) DIMENSION3
    ,NULL LABORLEVELNAME2
    ,NULL MACHINE_PROJECT
    ,NULL LOCATION_OTHER
    ,NULL LABORLEVELNAME3
    ,NULL LABORLEVELNAME4
    ,NULL LABORLEVELNAME5
    ,NULL LABORLEVELNAME6
    ,NULL LABORLEVELNAME7
    ,WORKRULE WORKRULENAME
    ,CAST(NULL AS INT) HOLIDAYID
    ,NULL HOLIDAYNAME
    ,CAST(NULL AS INT) TMSHTITEMTYPEID
    ,NULL TIMESHEETITEMTYPE
    ,CAST(NULL AS NUMERIC(28,0)) HASCOMMENTSSW
    ,CAST(NULL AS NUMERIC(28,0)) SCHEDWORKRULESW
    ,CAST(NULL AS INT) ORGID
    ,ActivityLevel4NameTask ORGNM
    ,CAST(NULL AS INT) ORGTYPEID
    ,ActivityLevel4NameTask ORGDSC
    ,CAST(NULL AS INT) ORGLEVELNBR
    ,CAST(NULL AS NUMERIC(28,0)) REPORTTOORGID
    ,CONCAT(ActivityLevel1NameMainCategory,'--',ActivityLevel1NameSubCategory,'/',ActivityLevel2NameCustomer,'--',ActivityLevel2NameBU,'--',ActivityLevel2NameSerialNo,'/',ActivityLevel3NameServiceOrder,'--',ActivityLevel3NameInstallationID,'/',ActivityLevel4NameTask) ORGPATHTXT
    ,CAST(NULL AS DATETIME) EFFECTIVEDTM
    ,CAST(NULL AS DATETIME) EXPIRATIONDTM
    ,UserDefinedField1 Two
    ,ActivityLevel2NameBU Three
    ,NULL Four
    ,NULL Five
    ,NULL Six
    ,NULL Seven
    ,NULL Eight
    ,ActivityLevel4NameTask TASK
    ,ActivityLevel1NameMainCategory || CASE WHEN ActivityLevel1NameSubCategory is NULL THEN '' ELSE '--'||ActivityLevel1NameSubCategory END TYPEOFWORK
    ,ActivityLevel2NameSerialNo MACHINESN
    ,IFNULL(Fab.FabId,FAB_Expired.FabID) FAB
    ,ActivityLevel3NameServiceOrder SO
    ,CAST(NULL AS INT) EMP_APPROVED
--   ,ActivityLevel2NameCustomer SOLDTO_BPID
--   ,FAB_OFFICE
    ,COMMENTS COMMENTS
    ,NULL NOTES
    ,TIMEPUNCHID
  FROM {{ ref('ODS__KRONOS__ACTIVITIESTOTAL') }} 
  LEFT OUTER JOIN {{ ref('COMMON__BAAN__FAB') }}
   ON Fab.CustomerId = ActivitiesTotal.ActivityLevel2NameCustomer
    AND Fab.IsExpired = 'No' 
  LEFT OUTER JOIN {{ ref('COMMON__BAAN__FAB') }} Fab_Expired
   ON Fab_Expired.CustomerId = ActivitiesTotal.ActivityLevel2NameCustomer  
    AND Fab_Expired.IsExpired = 'Yes'
  GROUP BY TransactionId 
,EmployeeNumber 
,HomeLaborCategory1CostStructure 
,LEFT(HomeLaborCategory1CostStructure,3) 
,SUBSTRING(HomeLaborCategory1CostStructure, 5, 4) 
,SUBSTRING(HomeLaborCategory1CostStructure, 10, 4) 
,SUBSTRING(HomeLaborCategory1CostStructure, 15, 4) 
,ApplyDate
,AdjustedStartDateTime 
,AdjustedEndDateTime
,HomeLaborCategory1CostStructure 
,PayCode
,SUBSTRING(HomeLaborCategory1CostStructure, 1, 3) 
,SUBSTRING(HomeLaborCategory1CostStructure, 5, 4) 
,SUBSTRING(HomeLaborCategory1CostStructure, 10, 4) 
,SUBSTRING(HomeLaborCategory1CostStructure, 15, 4) 
,EmployeeNumber 
,WORKRULE 
,ActivityLevel4NameTask 
,ActivityLevel4NameTask 
,CONCAT(ActivityLevel1NameMainCategory,'--',ActivityLevel1NameSubCategory,'/',ActivityLevel2NameCustomer,'--',ActivityLevel2NameBU,'--',ActivityLevel2NameSerialNo,'/',ActivityLevel3NameServiceOrder,'--',ActivityLevel3NameInstallationID,'/',ActivityLevel4NameTask) 
,UserDefinedField1 
,ActivityLevel2NameBU 
,ActivityLevel4NameTask 
,ActivityLevel1NameMainCategory || CASE WHEN ActivityLevel1NameSubCategory is NULL THEN '' ELSE '--'||ActivityLevel1NameSubCategory END
,ActivityLevel2NameSerialNo
,ActivityLevel3NameServiceOrder 
,COMMENTS
,TIMEPUNCHID
,IFNULL(Fab.FabId,FAB_Expired.FabID)
) as Qry_Timesheet

LEFT JOIN {{ ref('ODS__MDM__KRONOS_TYPE_OF_WORK_GROUP') }}  as Kronos_WG
ON Kronos_WG.Type_Of_Work =  QRY_Timesheet.TYPEOFWORK
WHERE 1=1
AND Machine_Serial_Number IS NOT NULL
--AND Machine_Serial_Number = 'G111495'
) as pvt

PIVOT
(SUM(Hours_Worked)
FOR General_Category IN ('Pre-Startup', 'Startup', 'Pre-Warranty', 'Warranty', 'FCN', 'Paid Service',
'Service Contract', 'TSC Service', 'Used Equipment', 'Modification', 'Concession', 'Technical Support',
'Training', 'Error')) AS pvt
) QRY_Timesheet_MachineTotals

)

,transform_data as (
   select 
      CONCESSION,
      ERROR,
      FCN_HOURS,
      MACHINE_SERIAL_NUMBER,
      MODIFICATION,
      PAID_SERVICE_HOURS,
      PRE_STARTUP_HOURS,
      PRE_WARRANTY_HOURS,
      SERVICE_CONTRACT_HOURS,
      STARTUP_HOURS,
      TECHNICAL_SUPPORT,
      TRAINING,
      TSC_SERVICE,
      USED_EQUIPMENT,
      WARRANTY_HOURS,
      '{{ invocation_id }}' AS AUDIT_LOG_ID
  from SourceData
)



,type_data as (
    SELECT
        CAST(CONCESSION AS NUMBER(38,2)) AS CONCESSION,
        CAST(ERROR AS NUMBER(38,2)) AS ERROR,
        CAST(FCN_HOURS AS NUMBER(38,2)) AS FCN_HOURS,
        CAST(MACHINE_SERIAL_NUMBER AS VARCHAR(16777216)) AS MACHINE_SERIAL_NUMBER,
        CAST(MODIFICATION AS NUMBER(38,2)) AS MODIFICATION,
        CAST(PAID_SERVICE_HOURS AS NUMBER(38,2)) AS PAID_SERVICE_HOURS,
        CAST(PRE_STARTUP_HOURS AS NUMBER(38,2)) AS PRE_STARTUP_HOURS,
        CAST(PRE_WARRANTY_HOURS AS NUMBER(38,2)) AS PRE_WARRANTY_HOURS,
        CAST(SERVICE_CONTRACT_HOURS AS NUMBER(38,2)) AS SERVICE_CONTRACT_HOURS,
        CAST(STARTUP_HOURS AS NUMBER(38,2)) AS STARTUP_HOURS,
        CAST(TECHNICAL_SUPPORT AS NUMBER(38,2)) AS TECHNICAL_SUPPORT,
        CAST(TRAINING AS NUMBER(38,2)) AS TRAINING,
        CAST(TSC_SERVICE AS NUMBER(38,2)) AS TSC_SERVICE,
        CAST(USED_EQUIPMENT AS NUMBER(38,2)) AS USED_EQUIPMENT,
        CAST(WARRANTY_HOURS AS NUMBER(38,2)) AS WARRANTY_HOURS,
        CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID
    FROM transform_data
)

SELECT * from type_data