{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='KRONOS_TIMESHEET'
) }}

/* Change log
-- EC7/12/2023 - reorganized code into CTEs, CAS160707, CAS160904
-- DG 03/19/2024 - adding more accurate reference to pull in Employee Data for Time off(requested by LK)
*/

/******************************** Time off Employee Data - QRY_Timesheet **********************/
WITH TIMEOFF AS (
    SELECT
        T.PERSONNUMBER,
        T.WORKEDSHIFTENDDATETIME,
        date_trunc('DAY', T.WORKEDSHIFTENDDATETIME) AS WORKEDSHIFTENDDATE,
        D.YEAR_MONTH_TEXT,
        D.PAY_PERIOD_END_DATE,
		    T.PERSONNUMBER||'_'||date_trunc('DAY', T.WORKEDSHIFTENDDATETIME)  AS EMPID_EVENTDATE, ---ADDED 3/13/24
		    T.PERSONNUMBER||'_'||D.PAY_PERIOD_END_DATE AS EMP_PAYPERIOD_N   --ADDED 3/13/24
    FROM {{ ref('BRONZE__TEH_FINANCE__KRONOS_TIMECARD') }} T
        LEFT OUTER JOIN {{ source('STATIC_OBJECTS', 'CALENDAR_DATE') }} D ON date_trunc('DAY', T.WORKEDSHIFTENDDATETIME) = D.CALENDAR_DATE
),

ACTIVITY AS (  --UPDATED  most of query 3/13/24
    SELECT
        (RIGHT('000000'||ActT.EmployeeNumber,6)||'_'||EventDate.PAY_PERIOD_END_DATE) AS EMP_PAYPERIOD_C,
        EventDate.Pay_Period_End_Date as PAYPERIODENDDATE,
        -- CASE
        --     WHEN LEN(WORKEDLABORCATEGORY1COSTSTRUCTURE) = 14 THEN LEFT(RIGHT(WORKEDLABORCATEGORY1COSTSTRUCTURE,5),3)
        --     ELSE SPLIT_PART(WORKEDLABORCATEGORY1COSTSTRUCTURE,'-',2)
        -- END AS DEPTCODE,
        -- CASE
        --     WHEN LEN(WORKEDLABORCATEGORY1COSTSTRUCTURE) = 14 THEN LEFT(RIGHT(WORKEDLABORCATEGORY1COSTSTRUCTURE,7),2)
        --     ELSE SPLIT_PART(WORKEDLABORCATEGORY1COSTSTRUCTURE,'-',3)
        -- END AS PRODLINECODE,
        -- CASE
        --     WHEN LEN(WORKEDLABORCATEGORY1COSTSTRUCTURE) = 14 THEN RIGHT(WORKEDLABORCATEGORY1COSTSTRUCTURE,10)
        -- 	    ELSE NULL
        -- END AS COSTCENTER,
        split_part(WORKEDLABORCATEGORY1COSTSTRUCTURE, '-', 2) as COSTCENTER,
        substr(COSTCENTER, 6, 3) as DEPTCODE,
        substr(COSTCENTER, 4, 2) as PRODLINECODE,
        CASE
            WHEN HomeLaborCategory1CostStructure = 'UTM-7000-5999-MAINE' THEN BAAN_CODE
            WHEN HomeLaborCategory1CostStructure IN ('-7000-5999-6510',  '-7601-5300-6510') THEN '6510'
            WHEN LEN(HomeLaborCategory1CostStructure) = 14 AND BAAN_CODE IS NOT NULL THEN BAAN_CODE
            WHEN LEN(HomeLaborCategory1CostStructure) > 14 THEN SUBSTRING(HomeLaborCategory1CostStructure, 15, 4)
            WHEN HOMEBS5TELOFFICE = 'Deer Valley, AZ' THEN '6331'
            WHEN HOMEBS5TELOFFICE = 'Albany, NY' THEN '6131'
            WHEN HOMEBS5TELOFFICE = 'North Chelmsford, MA' THEN '6162'
            WHEN HOMEBS5TELOFFICE = 'Richardson' THEN '6320'
            ELSE NULL
        END AS LOCATIONCODE,
        SUM(AllocatedHoursTimeinSeconds) AS HOURS
    FROM {{ ref('BRONZE__TEH_FINANCE__KRONOS_ACTIVITIESTOTAL') }} ActT
    LEFT JOIN {{ source('STATIC_OBJECTS', 'CALENDAR_DATE') }} EventDate ON EventDate.Calendar_Date = CAST(Applydate AS DATETIME)
    LEFT OUTER JOIN {{ ref('SILVER__TEH_FINANCE__SAP_REGION') }} REGION ON REGION.SAP_DESCRIPTION = ActT.HOMEBS5TELOFFICE
    WHERE CAST(ApplyDate AS DATETIME) >= '2021-09-04'
        AND ActT.Is_SoftDeleted = 'No'
        AND EventDate.Fiscal_Year_Number >= 2014
    GROUP BY
        (RIGHT('000000'||ActT.EmployeeNumber,6)||'_'||EventDate.PAY_PERIOD_END_DATE),
        EventDate.Pay_Period_End_Date,
        COSTCENTER,
        DEPTCODE,
        PRODLINECODE,
        CASE
            WHEN HomeLaborCategory1CostStructure = 'UTM-7000-5999-MAINE' THEN BAAN_CODE
            WHEN HomeLaborCategory1CostStructure IN ('-7000-5999-6510',  '-7601-5300-6510') THEN '6510'
            WHEN LEN(HomeLaborCategory1CostStructure) = 14 AND BAAN_CODE IS NOT NULL THEN BAAN_CODE
            WHEN LEN(HomeLaborCategory1CostStructure) > 14 THEN SUBSTRING(HomeLaborCategory1CostStructure, 15, 4)
            WHEN HOMEBS5TELOFFICE = 'Deer Valley, AZ' THEN '6331'
            WHEN HOMEBS5TELOFFICE = 'Albany, NY' THEN '6131'
            WHEN HOMEBS5TELOFFICE = 'North Chelmsford, MA' THEN '6162'
            WHEN HOMEBS5TELOFFICE = 'Richardson' THEN '6320'
            ELSE NULL
        END
    QUALIFY row_number() over ( partition by (EMP_PAYPERIOD_C) order by HOURS desc) = 1
),

HISTORY AS (
    SELECT
        EMPLOYEEID,
        DEPTCODE,
        PRODLINECODE,
        LOCATIONCODE,
		    COSTCENTER,
        ADPCOMPANY, --ADDED 3/18/24
		    EMPLOYEEID||'_'||LEFT(SNAPSHOT_DATE, 7) AS EMPID_SNAPSHOT, --ADDED 3/18/24
        LEFT(SNAPSHOT_DATE, 7) AS SNAPSHOTMONTH
    FROM {{ ref('SILVER__TEH_FINANCE__EMPLOYEE_TEACOMMON_HISTORICAL_MONTHLY_SNAPSHOT') }}
    WHERE SNAPSHOT_DATE >= '2021-09-01'
    QUALIFY row_number() over ( partition by (EMPLOYEEID||SNAPSHOT_DATE) order by SNAPSHOT_DATE desc) = 1 --ADDED 3/18/24
),
HISTORYHIRE AS (
    SELECT
        EMPLOYEEID,
        DEPTCODE,
        PRODLINECODE,
		    COSTCENTER, --ADDED 3/13/24
        ADPCOMPANY, --ADDED 3/18/2024
        LOCATIONCODE,
        LEFT(MIN(SNAPSHOT_DATE), 7) AS FIRSTMONTH
    FROM {{ ref('SILVER__TEH_FINANCE__EMPLOYEE_TEACOMMON_HISTORICAL_MONTHLY_SNAPSHOT') }}
    WHERE SNAPSHOT_DATE >= '2023-09-01'  --UPDATED 3/19/24
    GROUP BY
        EMPLOYEEID,
        DEPTCODE,
        PRODLINECODE,
		    COSTCENTER, --ADDED 3/13/24
        ADPCOMPANY, --ADDED 3/18/2024
        LOCATIONCODE  QUALIFY row_number() over (partition by EMPLOYEEID order by LEFT(MIN(SNAPSHOT_DATE), 7) Asc ) = 1
),
CURRENTEMPLOYEE AS (
    SELECT
        EMPLOYEEID,
        DEPTCODE,
        PRODLINECODE,
		    COSTCENTER, --ADDED 3/13/24
        ADPCOMPANY, --ADDED 3/18/2024
        LOCATIONCODE
    FROM {{ ref('SILVER__TEH_FINANCE__EMPLOYEE') }}
),
COMBINED AS (  --UPDATED  most of query 3/13/24
    SELECT
        TIMEOFF.PERSONNUMBER,
        TIMEOFF.EMPID_EVENTDATE,
        TIMEOFF.WORKEDSHIFTENDDATE,
        TIMEOFF.WORKEDSHIFTENDDATETIME,
        TIMEOFF.YEAR_MONTH_TEXT,
        TIMEOFF.PAY_PERIOD_END_DATE,
        CASE
            WHEN ACTIVITY.DEPTCODE IS NOT NULL THEN ACTIVITY.DEPTCODE
            WHEN HISTORY.DEPTCODE IS NOT NULL THEN HISTORY.DEPTCODE
            WHEN HISTORYHIRE.DEPTCODE IS NOT NULL THEN HISTORYHIRE.DEPTCODE
            ELSE CURRENTEMPLOYEE.DEPTCODE
        END AS DEPTCODE,
        CASE
            WHEN ACTIVITY.PRODLINECODE IS NOT NULL THEN ACTIVITY.PRODLINECODE
            WHEN HISTORY.PRODLINECODE IS NOT NULL THEN HISTORY.PRODLINECODE
            WHEN HISTORYHIRE.PRODLINECODE IS NOT NULL THEN HISTORYHIRE.PRODLINECODE
            ELSE CURRENTEMPLOYEE.PRODLINECODE
        END AS PRODLINECODE,
        CASE
		    WHEN TIMEOFF.PAY_PERIOD_END_DATE < '2023-05-01' THEN NULL
            WHEN ACTIVITY.COSTCENTER IS NOT NULL THEN ACTIVITY.COSTCENTER
            WHEN HISTORY.COSTCENTER IS NOT NULL THEN HISTORY.COSTCENTER
            WHEN HISTORYHIRE.COSTCENTER IS NOT NULL THEN HISTORYHIRE.COSTCENTER
            ELSE CURRENTEMPLOYEE.COSTCENTER
        END AS COSTCENTER,
        CASE  --ADDED 3/14/24
            WHEN ACTIVITY.LOCATIONCODE IS NOT NULL THEN ACTIVITY.LOCATIONCODE  --ADDED 3/19/24
            WHEN HISTORY.LOCATIONCODE IS NOT NULL THEN HISTORY.LOCATIONCODE
            WHEN HISTORYHIRE.LOCATIONCODE IS NOT NULL THEN HISTORYHIRE.LOCATIONCODE
            ELSE CURRENTEMPLOYEE.LOCATIONCODE
        END AS LOCATIONCODE,
        ACTIVITY.DEPTCODE AS ACTIVITY_DEPTCODE,
        ACTIVITY.PRODLINECODE AS ACTIVITY_PRODLINECODE,
        HISTORY.DEPTCODE AS HISTORY_DEPTCODE,
        HISTORY.PRODLINECODE AS HISTORY_PRODLINECODE,
        HISTORYHIRE.DEPTCODE AS HISTORYHIRE_DEPTCODE,
        HISTORYHIRE.PRODLINECODE AS HISTORYHIRE_PRODLINECODE,
        CURRENTEMPLOYEE.DEPTCODE AS CURRENT_DEPTCODE,
        CURRENTEMPLOYEE.PRODLINECODE AS CURRENT_PRODLINECODE,
        COALESCE(CURRENTEMPLOYEE.ADPCOMPANY,HISTORY.ADPCOMPANY, HISTORYHIRE.ADPCOMPANY) AS ADPCOMPANY  --ADDED 3/18/24
    FROM TIMEOFF
    LEFT OUTER JOIN ACTIVITY ON TIMEOFF.EMP_PAYPERIOD_N = ACTIVITY.EMP_PAYPERIOD_C
    LEFT OUTER JOIN HISTORY ON TIMEOFF.PERSONNUMBER = HISTORY.EMPLOYEEID AND TIMEOFF.YEAR_MONTH_TEXT = HISTORY.SNAPSHOTMONTH
    LEFT OUTER JOIN HISTORYHIRE ON TIMEOFF.PERSONNUMBER = HISTORYHIRE.EMPLOYEEID
    LEFT OUTER JOIN CURRENTEMPLOYEE ON TIMEOFF.PERSONNUMBER = CURRENTEMPLOYEE.EMPLOYEEID
    QUALIFY row_number() over ( partition by (TIMEOFF.EMPID_EVENTDATE) ORDER BY TIMEOFF.PAY_PERIOD_END_DATE) = 1
),

/******************************** Kronos Data - QRY_Timesheet **********************/

QRY_TS_SOURCE_O AS (
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
      ,NULL COMMENTS
      ,NULL NOTES
      ,NULL TIMEPUNCHID
      ,Fab.CustomerId FabCode
      ,NULL BaanCompanyId
	    ,NULL AS COSTCENTER  --NEW FIELD ADDED 3/13/24
    FROM {{ source('STATIC_OBJECTS', 'TEA_RECENT_TIMESHEET') }}
    LEFT OUTER JOIN {{ ref('SILVER__TEH_FINANCE__FAB') }}
      ON Fab.FabId = TEA_Recent_Timesheet.FAB
    WHERE DeletedSW = 0
    AND EventDate < '2021-09-04'
),

QRY_TS_SOURCE_N AS (
  SELECT
      'N' AS SourceSystem
      ,recordid
      ,NULL AS OrgIDSid
      ,PersonFullName
      ,Timecard.PersonNumber
      ,NULL AS HOme_LL1
      ,ADPCOMPANY AS HOME_ADP_CO
      ,COMBINED.DEPTCODE AS HOME_DIM1  --UPDATED 3/14/24
      ,COMBINED.PRODLINECODE AS HOME_DIM2  --UPDATED 3/14/24
      ,COMBINED.LOCATIONCODE AS HOME_DIM3  --UPDATED 3/14/24
      ,RecordCreatedDate
      ,CAST(Timecard.WorkedShiftEndDateTime AS DATETIME) EVENTDATE
      ,TimecardTransactionRoundedStartDateTime AS STARTDTM
      ,TimecardTransactionRoundedEndDateTime ENDDTM
      ,CASE
       WHEN Timecard.PaycodeEditName iLIKE '%On Call%' THEN 0
       ELSE TimecardTransactionActualHoursWorked * 3600
       END AS TIMEINSECONDS    --UPDATED 3/14/24
      ,PAYCODEID
      ,CASE
       WHEN TIMECARDTRANSACTIONTYPE iLIKE '%HOLIDAY%' THEN 'Holiday'
       ELSE REPLACE(Timecard.PaycodeEditName,'US-','')
       END AS PAYCODENAME  --UPDATED 3/14/24
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
      ,NULL COMMENTS
      ,WorkedShiftComments NOTES
      ,NULL TIMEPUNCHID
      ,NULL FabCode
      ,Company.CompanyId BaanCompanyId
	    ,COMBINED.COSTCENTER
    FROM {{ ref('BRONZE__TEH_FINANCE__KRONOS_TIMECARD') }} Timecard
    LEFT JOIN COMBINED  --UPDATED 3/14/24
    ON COMBINED.EMPID_EVENTDATE =  TIMECARD.PERSONNUMBER||'_'||date_trunc('DAY', TIMECARD.WORKEDSHIFTENDDATETIME)
    LEFT OUTER JOIN {{ ref('SILVER__TEH_FINANCE__GLOBAL_EMPLOYEE') }} EmployeeDimension
    ON EmployeeDimension.Employee_Id = Timecard.PersonNumber
    --AND CAST(Timecard.WorkedShiftEndDateTime AS DATETIME) >= EmployeeDimension.DW_Effective_DateTime
    --AND CAST(Timecard.WorkedShiftEndDateTime AS DATETIME) < EmployeeDimension.DW_Expiration_DateTime
    LEFT OUTER JOIN {{ ref('SILVER__TEH_FINANCE__MDM_COMPANY') }} as Company
    ON Company.ShortName = SPLIT_PART(HomePrimaryOrg,'/',4)
   -- LEFT OUTER JOIN {{ ref('SILVER__TEH_FINANCE__BAAN_OFFICE') }}   --NOT NEEDED
    --ON Office.OfficeName = SPLIT_PART(Timecard.HomePrimaryOrg,'/',5)
   -- AND Office.CompanyId = Company.CompanyId
    LEFT OUTER JOIN {{ ref('BRONZE__TEH_FINANCE__MDM_TIMECARDPAYCODE') }} HolidayPaycode
    ON HolidayPaycode.Name = Timecard.TimecardTransactionApplyTo
    WHERE 1=1
	--IFNULL(REPLACE(Timecard.PaycodeEditName,'US-',''),HolidayPaycode.Description) IS NOT NULL  --REMOVE NOT NEEDED
    AND CAST(Timecard.WorkedShiftEndDateTime AS DATETIME) >= '2021-09-04'
    AND Timecard.Is_SoftDeleted = 'No'
),

QRY_TS_SOURCE_C AS (
  SELECT DISTINCT
      'C' AS SourceSystem
      ,CAST(CAST(TransactionId AS INT) AS VARCHAR(16777216))
      ,NULL AS OrgIDSid
      ,NULL AS PersonFullName
      ,EmployeeNumber AS PersonNum
      ,HomeLaborCategory1CostStructure  AS HOME_LL1
      ,split_part(WORKEDLABORCATEGORY1COSTSTRUCTURE, '-', 1) AS Home_ADP_CO
    --   ,CASE
    --         WHEN LEN(WORKEDLABORCATEGORY1COSTSTRUCTURE) = 14 THEN LEFT(RIGHT(WORKEDLABORCATEGORY1COSTSTRUCTURE,5),3)
    --   	    WHEN RIGHT(WORKEDLABORCATEGORY1COSTSTRUCTURE,3) = 'TEE' AND LEN(HOMELABORCATEGORY1COSTSTRUCTURE) = 14 THEN LEFT(RIGHT(HOMELABORCATEGORY1COSTSTRUCTURE,5),3)  --ADDED 3/19/24
    --         ELSE SPLIT_PART(WORKEDLABORCATEGORY1COSTSTRUCTURE,'-',2)
    --    END AS HOME_DIM1
    --   ,CASE
    --         WHEN LEN(WORKEDLABORCATEGORY1COSTSTRUCTURE) = 14 THEN LEFT(RIGHT(WORKEDLABORCATEGORY1COSTSTRUCTURE,7),2)
    --         WHEN RIGHT(WORKEDLABORCATEGORY1COSTSTRUCTURE,3) = 'TEE' AND LEN(HOMELABORCATEGORY1COSTSTRUCTURE) = 14  THEN LEFT(RIGHT(HOMELABORCATEGORY1COSTSTRUCTURE,7),2)   --ADDED 3/19/24
    --         ELSE SPLIT_PART(WORKEDLABORCATEGORY1COSTSTRUCTURE,'-',3)
    --    END AS HOME_DIM2
      ,CASE
      	    WHEN RIGHT(WORKEDLABORCATEGORY1COSTSTRUCTURE,3) = 'TEE' THEN LEFT(RIGHT(HOMELABORCATEGORY1COSTSTRUCTURE,5),3)  --ADDED 3/19/24
            ELSE LEFT(RIGHT(WORKEDLABORCATEGORY1COSTSTRUCTURE,5),3)
       END AS HOME_DIM1
      ,CASE
            WHEN RIGHT(WORKEDLABORCATEGORY1COSTSTRUCTURE,3) = 'TEE' THEN LEFT(RIGHT(HOMELABORCATEGORY1COSTSTRUCTURE,7),2)   --ADDED 3/19/24
            ELSE LEFT(RIGHT(WORKEDLABORCATEGORY1COSTSTRUCTURE,7),2)
       END AS HOME_DIM2
      ,CASE
          WHEN HomeLaborCategory1CostStructure = 'UTM-7000-5999-MAINE' THEN BAAN_CODE
          WHEN HomeLaborCategory1CostStructure IN ('-7000-5999-6510',  '-7601-5300-6510') THEN '6510'
          WHEN LEN(HomeLaborCategory1CostStructure) = 14 AND BAAN_CODE IS NOT NULL THEN BAAN_CODE
          WHEN LEN(HomeLaborCategory1CostStructure) > 14 THEN SUBSTRING(HomeLaborCategory1CostStructure, 15, 4)
          WHEN HOMEBS5TELOFFICE = 'Deer Valley, AZ' THEN '6331'
          WHEN HOMEBS5TELOFFICE = 'Albany, NY' THEN '6131'
          WHEN HOMEBS5TELOFFICE = 'North Chelmsford, MA' THEN '6162'
          WHEN HOMEBS5TELOFFICE = 'Richardson' THEN '6320'
          ELSE NULL
      END  AS HOME_DIM3
      ,CAST(NULL AS DATETIME) ENTEREDONDTM
      ,CAST(ApplyDate AS DATETIME)AS EVENTDATE
      ,AdjustedStartDateTime STARTDTM
      ,AdjustedEndDateTime ENDDTM
      ,(AllocatedHoursTimeinSeconds * 3600) AS TIMEINSECONDS -- EC7/12/2023 - CAS 160707
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
      ,CASE WHEN UserDefinedField1 = 'Projects' THEN SPLIT_PART(ACTIVITYLEVEL1NAMEMAINCATEGORY,' ',0) ELSE NULL END Four
      ,CASE WHEN UserDefinedField1 = 'Projects' THEN REPLACE(ACTIVITYLEVEL1NAMEMAINCATEGORY,SPLIT_PART(ACTIVITYLEVEL1NAMEMAINCATEGORY,' ',0)||' Projects ', '') ELSE NULL END Five
      ,CASE WHEN UserDefinedField1 = 'Projects' THEN ACTIVITYLEVEL2NAMECUSTOMER ELSE NULL END Six
      ,CASE WHEN UserDefinedField1 = 'Projects' THEN ACTIVITYLEVEL3NAMESERVICEORDER ELSE NULL END Seven
      ,CASE WHEN UserDefinedField1 = 'Projects' THEN ACTIVITYLEVEL4NAMETASK ELSE NULL END Eight
      ,ActivityLevel4NameTask TASK
      ,ActivityLevel1NameMainCategory || CASE WHEN ActivityLevel1NameSubCategory is NULL THEN '' ELSE '--'||ActivityLevel1NameSubCategory END TYPEOFWORK
      ,ActivityLevel2NameSerialNo MACHINESN
      ,IFNULL(Fab.FabId,Fab_Expired.FabId) FAB
      ,ActivityLevel3NameServiceOrder SO
      ,CAST(NULL AS INT) EMP_APPROVED
      ,COMMENTS COMMENTS
      ,NULL NOTES
      ,TIMEPUNCHID
      ,CASE WHEN ActivityLevel1NameMainCategory ILIKE '%Projects%' THEN NULL
            ELSE NULLIF(ActivityLevel2NameCustomer,'NA')
      END FabCode
      ,NULL BaanCompanyId
	  ,CASE
            -- WHEN APPLYDATE >= '2023-05-01' AND  LEN(WORKEDLABORCATEGORY1COSTSTRUCTURE) = 14 THEN RIGHT(WORKEDLABORCATEGORY1COSTSTRUCTURE,10)  --UPDATED 3/19/24
            -- WHEN APPLYDATE >= '2023-05-01' AND LEN(HOMELABORCATEGORY1COSTSTRUCTURE) = 14 THEN RIGHT(HOMELABORCATEGORY1COSTSTRUCTURE,10)--ADDED 3/19/24
            WHEN APPLYDATE >= '2023-05-01' THEN RIGHT(WORKEDLABORCATEGORY1COSTSTRUCTURE,10)  --UPDATED 3/19/24
		    ELSE NULL
        END AS COSTCENTER,  --ADDED 3/13/24
    FROM {{ ref('BRONZE__TEH_FINANCE__KRONOS_ACTIVITIESTOTAL') }} ActivitiesTotal
    LEFT OUTER JOIN {{ ref('SILVER__TEH_FINANCE__FAB') }} AS FAB
      ON Fab.CustomerId = ActivitiesTotal.ActivityLevel2NameCustomer
      AND FAB.IsExpired = 'No'
    LEFT OUTER JOIN (
        select *
        from  {{ ref('SILVER__TEH_FINANCE__FAB') }}
        where not(customerid = '460490203' and FABID = 'GLOALB')) FAB_EXPIRED
      ON FAB_EXPIRED.CustomerId = ActivitiesTotal.ActivityLevel2NameCustomer
      AND FAB_EXPIRED.IsExpired = 'Yes'
    LEFT OUTER JOIN {{ ref('SILVER__TEH_FINANCE__SAP_REGION') }} REGION
      ON REGION.SAP_DESCRIPTION = ActivitiesTotal.HOMEBS5TELOFFICE
    WHERE CAST(ApplyDate AS DATETIME) >= '2021-09-04'
    AND ActivitiesTotal.Is_SoftDeleted = 'No'
),

QRY_Timesheet AS (
  SELECT * FROM QRY_TS_SOURCE_O
    UNION ALL
  SELECT * FROM QRY_TS_SOURCE_N
    UNION ALL
  SELECT * FROM QRY_TS_SOURCE_C
), -- end Kronos QRY_Timesheet


/******************************** Kronos Data - QRY_Notes **********************/
QRY_Notes AS (
   SELECT
          'O' AS SourceSystem
          ,CAST(CAST(KronosCombined.TimeSheetItemId AS INT) AS VARCHAR(16777216)) TimeSheetItemId
          ,LISTAGG(TO_CHAR(KronosCombined.NoteText), '; ') WITHIN GROUP (ORDER BY KronosCombined.TimeSheetItemId) NOTES
      FROM (
          SELECT
              NoteDetail.ComntNoteTxt AS NoteText
              ,Timesheet.TimeSheetItemId AS TimeSheetItemId
          FROM {{ source('STATIC_OBJECTS', 'TEA_RECENT_TIMESHEET') }} Timesheet
          JOIN {{ source('STATIC_OBJECTS', 'TSCOMMENTMM') }} CommentMM ON CommentMM.TimeSheetItemId = Timesheet.TimeSheetItemId
          JOIN {{ source('STATIC_OBJECTS', 'COMNTNOTEDTL') }} NoteDetail ON NoteDetail.ComntNoteId = CommentMM.ComntNoteId
          WHERE NULLIF(NoteDetail.ComntNoteTxt,'') IS NOT NULL
          UNION
          SELECT
              IFNULL(StartNoteDetail.ComntNoteTxt,'') || CASE WHEN NULLIF(StartNoteDetail.ComntNoteTxt,'') IS NOT NULL AND NULLIF(EndNoteDetail.ComntNoteTxt,'') IS NOT NULL  THEN ': ' ELSE '' END || IFNULL(EndNoteDetail.ComntNoteTxt,'') AS NoteText
              ,Timesheet.TimeSheetItemId AS TimeSheetItemId
          FROM {{ source('STATIC_OBJECTS', 'TEA_RECENT_TIMESHEET') }} Timesheet
          LEFT JOIN {{ source('STATIC_OBJECTS', 'PUNCHCOMMENTMM') }} StartPunch ON StartPunch.PunchEventId = Timesheet.StPunchId
          LEFT JOIN {{ source('STATIC_OBJECTS', 'COMNTNOTEDTL') }}  StartNoteDetail ON StartNoteDetail.ComntNoteId = StartPunch.ComntNoteId
          LEFT JOIN {{ source('STATIC_OBJECTS', 'PUNCHCOMMENTMM') }} EndPunch ON EndPunch.PunchEventId = Timesheet.EndPunchId
          LEFT JOIN {{ source('STATIC_OBJECTS', 'COMNTNOTEDTL') }}  EndNoteDetail ON EndNoteDetail.ComntNoteId = EndPunch.ComntNoteId
          WHERE COALESCE(NULLIF(StartNoteDetail.ComntNoteTxt,'-'), NULLIF(EndNoteDetail.ComntNoteTxt,'-')) IS NOT NULL
      ) KronosCombined
      GROUP BY KronosCombined.TimeSheetItemId

      UNION ALL

      SELECT
        'N' AS SourceSystem
        ,RecordId
        ,WorkedShiftComments NOTES
      FROM {{ ref('BRONZE__TEH_FINANCE__KRONOS_TIMECARD') }}
      WHERE NULLIF(WorkedShiftComments,'') IS NOT NULL
), -- end Kronos Data - QRY_Notes


/******************************** Kronos Data - QRY_Comments **********************/
QRY_Comments AS (
      SELECT
          'O' AS SourceSystem
          ,CAST(CAST(KronosCombined.TimeSheetItemId AS INT) AS VARCHAR(16777216)) TimeSheetItemId
          ,LISTAGG(TO_CHAR(KronosCombined.CommentText), '; ') WITHIN GROUP (ORDER BY KronosCombined.TimeSheetItemId) CommentText
      FROM (
          SELECT
              Timesheet.Comment1 AS CommentText
              ,Timesheet.TimeSheetItemId AS TimeSheetItemId
          FROM {{ source('STATIC_OBJECTS', 'TEA_RECENT_TIMESHEET') }} Timesheet
          WHERE Timesheet.Comment1 IS NOT NULL
          UNION
          SELECT
              RIGHT(StartComment.CommentText, LENGTH(StartComment.CommentText)-CASE WHEN LEFT(StartComment.CommentText, 1) = '_' THEN 1 ELSE 0 END) ||
                CASE WHEN NULLIF(StartComment.CommentText,'') IS NOT NULL AND NULLIF(  EndComment.CommentText,'') IS NOT NULL THEN ': ' ELSE '' END ||
                RIGHT(  EndComment.CommentText, LENGTH(  EndComment.CommentText)-CASE WHEN LEFT(  EndComment.CommentText, 1) = '_' THEN 1 ELSE 0 END) AS CommentText
              ,CAST(Timesheet.TimeSheetItemId AS INT) AS TimeSheetItemId
          FROM {{ source('STATIC_OBJECTS', 'TEA_RECENT_TIMESHEET') }} Timesheet
          LEFT JOIN {{ source('STATIC_OBJECTS', 'PUNCHCOMMENTMM') }} StartPunch ON StartPunch.PunchEventId = Timesheet.StPunchId
          LEFT JOIN {{ source('STATIC_OBJECTS', 'COMMENTS') }} StartComment ON StartComment.CommentId = StartPunch.CommentId
          LEFT JOIN {{ source('STATIC_OBJECTS', 'PUNCHCOMMENTMM') }} EndPunch ON EndPunch.PunchEventId = Timesheet.EndPunchId
          LEFT JOIN {{ source('STATIC_OBJECTS', 'COMMENTS') }}  EndComment ON EndComment.CommentId = EndPunch.CommentId
          WHERE COALESCE(StartComment.CommentText, EndComment.CommentText) IS NOT NULL
      ) KronosCombined
      GROUP BY KronosCombined.TimeSheetItemId

      UNION ALL

      SELECT
        'C' AS SourceSystem
        ,CAST(CAST(TransactionId AS INT) AS VARCHAR(16777216)) AS TransactionId
        ,LISTAGG(TO_CHAR(Comments), '; ') WITHIN GROUP (ORDER BY TransactionId) CommentText
      FROM {{ ref('BRONZE__TEH_FINANCE__KRONOS_ACTIVITIESTOTAL') }}
      WHERE NULLIF(Comments,'') IS NOT NULL
      GROUP BY TransactionId
), -- end Kronos Data QRY_Commnets


/******************************** Kronos Data- QRY_Commets_OT **********************/
QRY_Comments_OT AS (
  SELECT
          'O' AS SourceSystem
          ,CAST(CAST(KronosCombined.TimeSheetItemId AS INT) AS VARCHAR(16777216)) TimeSheetItemId
          ,LISTAGG(TO_CHAR(KronosCombined.CommentText), '; ') WITHIN GROUP (ORDER BY KronosCombined.TimeSheetItemId) CommentText
      FROM (
          SELECT
              Timesheet.Comment1 AS CommentText
              ,Timesheet.TimeSheetItemId AS TimeSheetItemId
          FROM {{ source('STATIC_OBJECTS', 'TEA_RECENT_TIMESHEET') }}  Timesheet
          WHERE Timesheet.Comment1 IS NOT NULL
          UNION
          SELECT
              RIGHT(StartComment.CommentText, LENGTH(StartComment.CommentText)-CASE WHEN LEFT(StartComment.CommentText, 1) = '_' THEN 1 ELSE 0 END) ||
                CASE WHEN NULLIF(StartComment.CommentText,'') IS NOT NULL AND NULLIF(  EndComment.CommentText,'') IS NOT NULL THEN ': ' ELSE '' END ||
                RIGHT(  EndComment.CommentText, LENGTH(  EndComment.CommentText)-CASE WHEN LEFT(  EndComment.CommentText, 1) = '_' THEN 1 ELSE 0 END) AS CommentText
              ,CAST(Timesheet.TimeSheetItemId AS INT) AS TimeSheetItemId
          FROM {{ source('STATIC_OBJECTS', 'TEA_RECENT_TIMESHEET') }}  Timesheet
          LEFT JOIN {{ source('STATIC_OBJECTS', 'PUNCHCOMMENTMM') }} StartPunch ON StartPunch.PunchEventId = Timesheet.StPunchId
          LEFT JOIN {{ source('STATIC_OBJECTS', 'COMMENTS') }}  StartComment ON StartComment.CommentId = StartPunch.CommentId
          LEFT JOIN {{ source('STATIC_OBJECTS', 'PUNCHCOMMENTMM') }} EndPunch ON EndPunch.PunchEventId = Timesheet.EndPunchId
          LEFT JOIN {{ source('STATIC_OBJECTS', 'COMMENTS') }}  EndComment ON EndComment.CommentId = EndPunch.CommentId
          WHERE COALESCE(StartComment.CommentText, EndComment.CommentText) IS NOT NULL
      ) KronosCombined
      GROUP BY KronosCombined.TimeSheetItemId

      UNION ALL

      SELECT
        'C' AS SourceSystem
        ,CAST(CAST(TransactionId AS INT) AS VARCHAR(16777216)) AS TransactionId
        ,LISTAGG(TO_CHAR(Comments), '; ') WITHIN GROUP (ORDER BY TransactionId) CommentText
      FROM {{ ref('BRONZE__TEH_FINANCE__KRONOS_ACTIVITIESTOTAL') }}
      WHERE NULLIF(Comments,'') IS NOT NULL
      GROUP BY TransactionId
),  -- end Kronos Data QRY_Commnets


/******************************** CRM data **********************/
crm_account AS (
  SELECT
    ACCOUNTNUMBER,
    NAME
  FROM {{ ref('BRONZE__TEH_FINANCE__CRM_FILE_ACCOUNT') }}
  WHERE LEFT(ACCOUNTNUMBER,1) IN ('B','D')
    AND LEFT(COM_COUNTRY_MASTER_CD,3) IN ('USA', 'CAN', 'MEX')
    AND NAME IS NOT NULL
),

wo_msdyn_timeentry AS (
  SELECT
    TE.ID,
    TE.TEL_WO_CATEGORYNAME,
    TE.TEL_WO_BU2NAME,
    TE.WO_REGIONNAME,
    TE.WO_TASK2NAME,
    payment_type.TEL_WO_TYPEOFPAYMENT,
    tc.WO_TIMECATEGORY,
    TE.WO_WORKORDERNONAME
  FROM {{ ref('BRONZE__TEH_FINANCE__CRM_FILE_MSDYN_TIMEENTRY') }} TE
  LEFT OUTER JOIN (
        select
          OPTION,
          LOCALIZEDLABEL AS TEL_WO_TYPEOFPAYMENT
        FROM {{ ref('BRONZE__TEH_FINANCE__CRM_FILE_GLOBALOPTIONSETMETADATA') }}
        WHERE OPTIONSETNAME = 'tel_wo_typeofpayment'
        AND LOCALIZEDLABELLANGUAGECODE = '1033'
        AND ENTITYNAME = 'msdyn_timeentry'
      ) payment_type on TE.TEL_WO_TYPEOFPAYMENT = payment_type.OPTION
  LEFT OUTER JOIN (
        SELECT
          OPTION
          ,LOCALIZEDLABEL AS WO_TIMECATEGORY
        FROM {{ ref('BRONZE__TEH_FINANCE__CRM_FILE_GLOBALOPTIONSETMETADATA') }}
        WHERE OPTIONSETNAME = 'wo_timecategory'
        AND LOCALIZEDLABELLANGUAGECODE = '1033'
        AND ENTITYNAME = 'msdyn_timeentry'
      ) tc on TE.WO_TIMECATEGORY = tc.OPTION
),

GUID AS (
    SELECT
      CONCAT('{',UPPER(ID),'}') AS CRM_TE_GUID
      ,MSDYN_NAME AS CRMWORKORDER
    FROM {{ ref('BRONZE__TEH_FINANCE__CRM_FILE_MSDYN_TIMEENTRY') }} TE
    LEFT OUTER JOIN {{ ref('SILVER__TEH_FINANCE__WORKORDER') }} WO
      ON TE.WO_WORKORDERNO = WO.WORK_ORDER_ID
),

SAPSO AS (
  SELECT DISTINCT
    TEL_WO_SERVICEORDERNO_3200
  FROM {{ ref('SILVER__TEH_FINANCE__WO_SUMMARY_DETAILS') }}
  WHERE TEL_WO_SERVICEORDERNO_3200 IS NOT NULL
), -- end of CRM Data


/******************************** SAPH data **********************/
SAP_SEGMENT AS (
  SELECT DISTINCT SAP_CODE,SAP_DESCRIPTION
  FROM {{ ref('SILVER__TEH_FINANCE__SAP_SEGMENT') }}
),   -- end SAPH data


/******************************** Combined Kronos Data **********************/
kronos_data as (

  SELECT
  CASE --UPDATED 3/18/24
    WHEN MDM_ADP_Code_Mapping.Company_Name IS NOT NULL  AND QRY_Timesheet.SourceSystem = 'O' THEN  MDM_ADP_Code_Mapping.Company_Name
    ELSE QRY_Timesheet.HOME_ADP_CO
  END AS ADPCompany,
  RIGHT('000000'||IFNULL(QRY_Timesheet.LABORLEVELNAME7, TEA_Common_Employee.SupervisorID),6) AS ApprovingSupervisorId,
  CASE
    WHEN QRY_Timesheet.EVENTDATE >= '2023-05-01'AND QRY_Timesheet.HOME_DIM2 = '5100' THEN '17'  --ADDED 3/18/24
    WHEN QRY_Timesheet.EVENTDATE >= '2023-05-01'AND QRY_Timesheet.HOME_DIM2 = '5200' THEN '18' --ADDED 3/18/24
    WHEN QRY_Timesheet.EVENTDATE >= '2023-05-01'AND QRY_Timesheet.HOME_DIM2 = '5300' THEN '19' --ADDED 3/18/24
    WHEN QRY_Timesheet.EVENTDATE >= '2023-05-01'AND QRY_Timesheet.HOME_DIM2 = '5400' THEN '21' --ADDED 3/18/24
    WHEN QRY_Timesheet.EVENTDATE >= '2023-05-01'AND QRY_Timesheet.HOME_DIM2 = '5999' THEN '33' --ADDED 3/19/24
    ELSE QRY_Timesheet.HOME_DIM2
  END as BUCode,
  CASE
  WHEN QRY_Timesheet.SourceSystem = 'N' THEN 'Time Off'
  WHEN QRY_Timesheet.SourceSystem = 'C' THEN MDM_TASTypeOfWork.Billable_Category_Group
  WHEN QRY_Timesheet.TypeOfWork = 'CON001728' THEN 'Billable'
  WHEN QRY_Timesheet.TypeOfWork = 'CON001745' THEN 'Billable'
  WHEN QRY_Timesheet.TypeOfWork = 'FLX001278' THEN 'Billable'
  WHEN QRY_Timesheet.TypeOfWork = 'FR0000001' THEN 'Billable'
  WHEN QRY_Timesheet.TypeOfWork = 'FR0000002' THEN 'Billable'
  WHEN QRY_Timesheet.TypeOfWork = 'FR0000003' THEN 'Billable'
  WHEN QRY_Timesheet.PAYCODENAME IN ('Regular', 'Overtime', 'Hours Worked') AND QRY_Timesheet.TypeOfWork IS NULL THEN 'Non-Billable'
  WHEN QRY_Timesheet.PAYCODENAME <> 'Hours Worked' THEN 'Time Off'
  WHEN QRY_Timesheet.TWO = 'Projects' AND QRY_Timesheet.FIVE = 'Fixed Asset Work' THEN 'Billable'
  WHEN QRY_Timesheet.TWO = 'Projects' AND QRY_Timesheet.FOUR = 'QRS Facility Work' THEN 'Billable'
  WHEN QRY_Timesheet.TWO = 'Projects' AND QRY_Timesheet.THREE = 'WFC6' THEN 'Non-Billable'
  WHEN QRY_Timesheet.TWO = 'Projects' AND QRY_Timesheet.FOUR = 'MS Tech Support' THEN 'Billable'
  WHEN QRY_Timesheet.TWO = 'Projects' AND QRY_Timesheet.FOUR IN ( 'CUE' ,  'TMEA - CUE') THEN 'Billable'
  WHEN QRY_Timesheet.TWO = 'Projects' AND QRY_Timesheet.THREE = 'TTCA' AND QRY_Timesheet.FOUR = 'Intercompany Labor' THEN 'Billable'
  WHEN QRY_Timesheet.TWO = 'Projects' AND QRY_Timesheet.THREE = 'TEA' AND QRY_Timesheet.FOUR IN ('FST', 'Technical Training') AND QRY_Timesheet.FIVE = 'Training' THEN 'Training'
  WHEN QRY_Timesheet.TWO = 'Projects' AND (QRY_Timesheet.Three <> 'TTCA' OR QRY_Timesheet.FOUR <> 'Intercompany Labor' OR QRY_Timesheet.FOUR <> 'MS Tech Support' OR QRY_Timesheet.FOUR <> 'CUE') THEN 'Projects'
  WHEN QRY_Timesheet.PAYCODENAME = 'Hours Worked' AND QRY_Timesheet.TYPEOFWORK = 'Sales-Customer Support' AND TEA_Common_Employee.DeptCode IN ('7600','7601') THEN 'Billable'
  WHEN QRY_Timesheet.PAYCODENAME = 'Hours Worked' AND QRY_Timesheet.TWO IS NULL THEN 'Non-Billable'
  ELSE MDM_TASTypeOfWork.Billable_Category_Group
  END AS BillableCategory,
  COALESCE( CommentCleanup.CleanedValue,QRY_Comments.CommentText) as Comment,
  CASE
  WHEN QRY_Timesheet.EVENTDATE >= '2023-05-01'AND QRY_Timesheet.HOME_DIM1 = '7000' THEN '048'  --ADDED 3/18/24
  WHEN QRY_Timesheet.EVENTDATE >= '2023-05-01'AND QRY_Timesheet.HOME_DIM1 = '7600' THEN '053'  --ADDED 3/18/24
  WHEN QRY_Timesheet.EVENTDATE >= '2023-05-01'AND QRY_Timesheet.HOME_DIM1 = '7601' THEN '054'  --ADDED 3/18/24
  WHEN QRY_Timesheet.EVENTDATE >= '2023-05-01'AND QRY_Timesheet.HOME_DIM1 = '9932' THEN '096'  --ADDED 3/19/24
  WHEN QRY_Timesheet.EVENTDATE >= '2023-05-01'AND QRY_Timesheet.HOME_DIM1 = '9935' THEN '099'  --ADDED 3/19/24
  ELSE QRY_Timesheet.HOME_DIM1
  END as DepartmentId,
  COALESCE(SegmentMapping.SegmentShortName,SAP_SEGMENT.SAP_DESCRIPTION) as EmpBUName,
  COALESCE(QRY_Timesheet.PERSONFULLNAME,CONCAT(TEA_Common_Employee .LASTNAME,', ',TEA_Common_Employee .FIRSTNAME)) as EmployeeFullName,
  RIGHT('000000'||QRY_Timesheet.PERSONNUM,6) as EmployeeId,
  CASE
    WHEN QRY_Timesheet.HOME_ADP_CO = 'TMP' THEN 'Subcon'
    WHEN QRY_Timesheet.HOME_ADP_CO IN ('TEF','TVC') THEN 'FTE'
    WHEN MDM_ADP_Code_Mapping.Company_Name IN ('TEA', 'TEA Ex-pat', 'TEF', 'TEF Ex-pat', 'TEH', 'TEH Ex-pat', 'TEI', 'TEN', 'TEN Ex-pat','TTCA', 'TTCA Ex-pat','TVC')  THEN 'FTE'
  ELSE 'Subcon'
  END as EmployeeType,
  QRY_Timesheet.ENDDTM as EndTimestamp,
  QRY_Timesheet.ENTEREDONDTM as EnteredOnTimestamp,
  TO_DATE(QRY_Timesheet.EVENTDATE) as EventDate,
  QRY_Timesheet.EVENTDATE as EventTimestamp,
  CASE
    WHEN QRY_Timesheet.SourceSystem = 'C' THEN QRY_Timesheet.FAB
    WHEN QRY_Timesheet.PAYCODENAME = 'Hours Worked' THEN QRY_Timesheet.FAB
    ELSE NULL
  END as FAB,
  CASE
    WHEN QRY_Timesheet.SourceSystem = 'N' THEN NULL
    WHEN QRY_Timesheet.SourceSystem = 'C' THEN QRY_Timesheet.FABCODE
    WHEN QRY_Timesheet.PayCodeName = 'Hours Worked' THEN QRY_Timesheet.FABCODE
    ELSE NULL
  END as FabCode,
  CASE
    WHEN QRY_Timesheet.PAYCODENAME = 'On Call' THEN 0
    ELSE IFNULL(QRY_Timesheet.TIMEINSECONDS,0) / 3600
  END as HoursCharged,
  CASE
    WHEN QRY_Timesheet.EMP_APPROVED = 1 THEN 'Yes'
    ELSE 'No'
  END as IsEmployeeApproved,
  CASE
    WHEN QRY_Timesheet.SOURCESYSTEM = 'N' THEN NULL
    WHEN QRY_Timesheet.SOURCESYSTEM = 'C' THEN NULLIF(COALESCE( WisdomMachine.BU_GROUP, MachineBU.BU_GROUP,QRY_Timesheet.THREE),'NA')
    WHEN QRY_Timesheet.SOURCESYSTEM = 'O' AND QRY_Timesheet.PAYCODENAME = 'Hours Worked' AND QRY_Timesheet.TWO = 'Projects' THEN 'Projects'
    WHEN QRY_Timesheet.SOURCESYSTEM = 'O' AND QRY_Timesheet.PAYCODENAME = 'Hours Worked' THEN IFNULL( MachineBU.BU_GROUP,QRY_Timesheet.THREE)
    ELSE NULL
  END as MachineBU,
  CASE
    WHEN QRY_Timesheet.SOURCESYSTEM = 'O' AND QRY_Timesheet.PAYCODENAME = 'Hours Worked' THEN QRY_Timesheet.MACHINESN
    WHEN QRY_Timesheet.SOURCESYSTEM = 'C' THEN NULLIF(QRY_Timesheet.MACHINESN,'NA')
    ELSE NULL
  END as MachineSerialNumber,
  QRY_Notes.NOTES as Notes,
  COALESCE(OTCommentCleanup.CleanedValue, QRY_Comments_OT.CommentText ) as OTComment,
  QRY_Timesheet.HOME_DIM3 as OfficeId,
  CASE
    WHEN QRY_Timesheet.PAYCODENAME = 'Hours Worked' THEN QRY_Timesheet.TWO
    ELSE NULL
  END as OrgMapType,
  QRY_Timesheet.ORGPATHTXT as OrgPathText,
  QRY_Timesheet.PAYCODENAME as PayCodeName,
  CASE
      WHEN QRY_Timesheet.SourceSystem = 'O' AND QRY_Timesheet.PayCodeName <> 'Hours Worked' THEN NULL --Required due to Legacy system Error
      WHEN QRY_Timesheet.SourceSystem = 'O' AND QRY_Timesheet.TWO = 'Projects' THEN NULL  --ORGMAPTYPE is same as TWO field in ODS_KRONOS.TEA_RECENT_TIMESHEET
      ELSE MDM_TASTypeOfWork.Legacy_Type_Of_Work --To Be Revenue_Product_SubCategory
  END as ProductSubCategory,   --PRODUCTSUBCATEGORY
  CASE
      WHEN QRY_Timesheet.SourceSystem = 'O' AND QRY_Timesheet.PayCodeName <> 'Hours Worked' THEN NULL --Required due to Legacy system Error
      WHEN QRY_Timesheet.SourceSystem = 'O' AND QRY_Timesheet.TWO = 'Projects' THEN NULL  --ORGMAPTYPE is same as TWO field in ODS_KRONOS.TEA_RECENT_TIMESHEET
      ELSE MDM_TASTypeOfWork.Source   --To Be Revenue_Product_Type_Code
  END as ProductType, -- PRODUCTTYPE
  CASE
    WHEN  QRY_Timesheet.SOURCESYSTEM = 'O' AND QRY_Timesheet.TWO = 'Projects' THEN QRY_Timesheet.THREE
    WHEN  QRY_Timesheet.SOURCESYSTEM = 'C' THEN  QRY_Timesheet.FOUR
    ELSE NULL
  END as ProjectCompany,
  CASE
    WHEN  QRY_Timesheet.SOURCESYSTEM = 'O' AND QRY_Timesheet.TWO = 'Projects' THEN QRY_Timesheet.FOUR
    WHEN  QRY_Timesheet.SOURCESYSTEM = 'C' THEN  QRY_Timesheet.FIVE
    ELSE NULL
  END as ProjectGroup,
  CASE
    WHEN  QRY_Timesheet.SOURCESYSTEM = 'O' AND QRY_Timesheet.TWO = 'Projects' THEN QRY_Timesheet.FIVE
    WHEN  QRY_Timesheet.SOURCESYSTEM = 'C' THEN  QRY_Timesheet.SIX
    ELSE NULL
  END as ProjectSubGroup,
  CASE
    WHEN QRY_Timesheet.SOURCESYSTEM = 'O' AND QRY_Timesheet.TWO = 'Projects' THEN CASE WHEN QRY_Timesheet.SIX IN ('FR0000001', 'FR0000002', 'FR0000003') THEN QRY_Timesheet.SIX ELSE QRY_Timesheet.SEVEN END
    WHEN QRY_Timesheet.SOURCESYSTEM = 'C' THEN  QRY_Timesheet.EIGHT
    ELSE NULL
  END as ProjectTask,
  CASE
    WHEN  QRY_Timesheet.SOURCESYSTEM = 'O' AND QRY_Timesheet.TWO = 'Projects' THEN CASE WHEN QRY_Timesheet.SIX IN ('FR0000001', 'FR0000002', 'FR0000003') THEN QRY_Timesheet.SEVEN ELSE QRY_Timesheet.SIX END
    WHEN  QRY_Timesheet.SOURCESYSTEM = 'C' THEN  QRY_Timesheet.SEVEN
    ELSE NULL
  END as ProjectTypeOfWork,
  CASE
    WHEN QRY_Timesheet.SOURCESYSTEM = 'C' AND QRY_Timesheet.TWO = 'Projects' THEN NULL
    WHEN QRY_Timesheet.SOURCESYSTEM = 'C' AND QRY_Timesheet.SO LIKE '%.%' THEN SPLIT_PART(SO,'.',1)
    WHEN QRY_Timesheet.SOURCESYSTEM = 'C' THEN NULLIF(QRY_Timesheet.SO,'NA')
    WHEN QRY_Timesheet.SOURCESYSTEM = 'N' THEN QRY_Timesheet.SO
    WHEN QRY_Timesheet.SOURCESYSTEM = 'O' AND QRY_Timesheet.PAYCODENAME = 'Hours Worked' AND QRY_Timesheet.SOURCESYSTEM  = 'O' THEN
        CASE
          WHEN QRY_Timesheet.SIX IN ('FR0000001', 'FR0000002', 'FR0000003') THEN QRY_Timesheet.TYPEOFWORK
          ELSE QRY_Timesheet.SO
        END
    ELSE NULL
  END as ServiceOrder,
  Kronos_Shift_Table.Shift_Indicated as ShiftNumber,
  Kronos_Shift_Table.Shift_Type as ShiftType,
  QRY_Timesheet.SourceSystem as SourceSystem,
  QRY_Timesheet.STARTDTM as StartTimestamp,
  CASE
    WHEN QRY_Timesheet.SourceSystem = 'C' THEN NULLIF(QRY_Timesheet.TASK,'NA')
    WHEN QRY_Timesheet.PAYCODENAME = 'Hours Worked' AND QRY_Timesheet.TWO =  'Projects' THEN 'Project Task'
    WHEN QRY_Timesheet.PAYCODENAME = 'Hours Worked' AND QRY_Timesheet.TWO <> 'Projects' THEN QRY_Timesheet.TASK
    ELSE NULL
  END as Task,
  QRY_Timesheet.TASK as TaskSource,
  CASE
  WHEN QRY_Timesheet.SourceSystem = 'N' THEN 'Time Off'
  WHEN QRY_Timesheet.SourceSystem = 'C' AND NULLIF(QRY_Timesheet.TASK,'NA') IS NULL THEN 'No Code'
  WHEN QRY_Timesheet.SourceSystem = 'C' THEN  TASTask.TAS_Wrench_Type
  WHEN QRY_Timesheet.PAYCODENAME = 'On Call' THEN 'On Call'
  WHEN QRY_Timesheet.PAYCODENAME <> 'Hours Worked' THEN 'Time Off'
  WHEN QRY_Timesheet.TWO IS NULL THEN 'No Code'
  WHEN QRY_Timesheet.TWO = 'Machines' AND QRY_Timesheet.TASK IS NULL THEN 'Error'
  WHEN QRY_Timesheet.TWO = 'Projects' AND QRY_Timesheet.THREE = 'WFC6' THEN 'No Code'
  WHEN QRY_Timesheet.TWO = 'Projects' AND QRY_Timesheet.THREE = 'TEA' AND QRY_Timesheet.FOUR IN ('FST', 'Technical Training') AND QRY_Timesheet.FIVE = 'Training' AND CASE WHEN QRY_Timesheet.SIX IN ('FR0000001', 'FR0000002', 'FR0000003') THEN QRY_Timesheet.SIX ELSE QRY_Timesheet.SEVEN END = 'Travel' THEN 'Travel'
  WHEN QRY_Timesheet.TWO = 'Projects' AND QRY_Timesheet.THREE = 'TEA' AND QRY_Timesheet.FOUR IN ('FST', 'Technical Training') AND QRY_Timesheet.FIVE = 'Training' AND CASE WHEN QRY_Timesheet.SIX IN ('FR0000001', 'FR0000002', 'FR0000003') THEN QRY_Timesheet.SIX ELSE QRY_Timesheet.SEVEN END <> 'Travel' THEN 'Training'
  WHEN QRY_Timesheet.TWO = 'Projects' THEN 'Projects'
  ELSE MDM_Wrench_Time_Mapping.Task_Wrench_Type
  END as TaskWrenchType,
  CASE
    WHEN QRY_Timesheet.PAYCODENAME = 'On Call' THEN 0
    ELSE IFNULL(QRY_Timesheet.TIMEINSECONDS,0)
  END as TimeInSeconds,
  TRIM(QRY_Timesheet.TIMEPUNCHID,'{}') as TimePunchId,
  QRY_Timesheet.TIMESHEETITEMID as TimesheetItemId,
  CASE
      WHEN QRY_Timesheet.SourceSystem = 'N' THEN 'Time Off'
      WHEN QRY_Timesheet.SourceSystem = 'O' AND QRY_Timesheet.PayCodeName <> 'Hours Worked' THEN 'Time Off'
      WHEN QRY_Timesheet.SourceSystem = 'O' AND QRY_Timesheet.Two = 'Projects' THEN 'Projects'
      WHEN QRY_Timesheet.SourceSystem = 'O' AND QRY_Timesheet.PayCodeName = 'Hours Worked' AND QRY_Timesheet.TypeOfWork IS NULL THEN 'Unallocated Time'
      ELSE MDM_TASTypeOfWork.Tas_Type_Of_Work
  END as TypeOfWork,
  CASE
      WHEN QRY_Timesheet.SourceSystem = 'N' THEN 'Time Off'
      WHEN QRY_Timesheet.SourceSystem = 'O' AND QRY_Timesheet.PayCodeName <> 'Hours Worked' THEN 'Time Off'
      WHEN QRY_Timesheet.SourceSystem = 'O' AND QRY_Timesheet.Two = 'Projects' THEN 'Projects'
      WHEN QRY_Timesheet.SourceSystem = 'O' AND QRY_Timesheet.PAYCODENAME = 'Hours Worked' AND QRY_Timesheet.TypeOfWork IS NULL THEN 'Unallocated Time'
      ELSE MDM_TASTypeOfWork.Tas_Type_Of_Work_Group
  END as TypeOfWorkGroup,
  CASE
    WHEN QRY_Timesheet.SourceSystem = 'O' AND QRY_Timesheet.TWO = 'Projects' THEN 'Projects'
    ELSE QRY_Timesheet.TYPEOFWORK
  END as TypeOfWorkSource,
  QRY_Timesheet.WORKRULENAME as WorkRuleName,
  CASE
    WHEN QRY_Timesheet.SOURCESYSTEM = 'C' AND QRY_Timesheet.SO LIKE '%.%' THEN SPLIT_PART(SO,'.',2)
    ELSE NULL
  END AS SAPOPERATION,
  GUID.CRMWORKORDER AS CRMWORKORDER, -- EC7/12/2023 CAS160904
  CASE  --UPDATED 3/19/24
    WHEN QRY_Timesheet.EVENTDATE < '2023-05-01' THEN NULL
	  ELSE COALESCE(QRY_Timesheet.COSTCENTER,HISTORY.COSTCENTER)
  END AS EMPCOSTCENTER,
  BUMAP.BU_GROUP AS EMPSERVICEBUGROUP
  FROM QRY_Timesheet
  LEFT OUTER JOIN QRY_Notes ON QRY_Notes.SourceSystem = QRY_Timesheet.SourceSystem
    AND QRY_Notes.TimesheetItemId = QRY_Timesheet.TimesheetItemId
  LEFT OUTER JOIN QRY_Comments ON QRY_Comments.SourceSystem =  QRY_Timesheet.SourceSystem
    AND QRY_Comments.TIMESHEETITEMID =  QRY_Timesheet.TIMESHEETITEMID
  LEFT OUTER JOIN {{ source('STATIC_OBJECTS', 'KRONOS_COMMENT_CLEANUP') }} CommentCleanup ON CommentCleanup.CommentType = 'Normal'
    AND QRY_Comments.CommentText ilike CommentCleanup.CurrentValue
  LEFT OUTER JOIN QRY_Comments_OT ON QRY_Comments_OT.SourceSystem =  QRY_Timesheet.SourceSystem
    AND QRY_Comments_OT.TimesheetItemId =  QRY_Timesheet.TimesheetItemId
  LEFT OUTER JOIN GUID ON GUID.CRM_TE_GUID = QRY_Timesheet.TIMEPUNCHID
  LEFT OUTER JOIN SAPSO ON SPLIT_PART(QRY_Timesheet.SO, '.', 1) = SAPSO.TEL_WO_SERVICEORDERNO_3200 --EC7/12/2023 - CAS160904
  LEFT OUTER JOIN {{ source('STATIC_OBJECTS', 'KRONOS_COMMENT_CLEANUP') }} OTCommentCleanup ON OTCommentCleanup.CommentType = 'Normal'
    AND QRY_Comments.CommentText ilike OTCommentCleanup.CurrentValue
  LEFT OUTER JOIN {{ ref('BRONZE__TEH_FINANCE__MDM_FST_KRONOS_WRENCH_TIME_MAPPING') }} MDM_Wrench_Time_Mapping ON MDM_Wrench_Time_Mapping.Paycode_Name = QRY_Timesheet.PAYCODENAME
    AND MDM_Wrench_Time_Mapping.Org_Map_Type =  QRY_Timesheet.TWO
    AND MDM_Wrench_Time_Mapping.Task =  QRY_Timesheet.TASK
  LEFT OUTER JOIN {{ ref('BRONZE__TEH_FINANCE__SHAREPOINT_TASTYPEOFWORK') }} MDM_TASTypeOfWork ON MDM_TASTypeOfWork.Type_of_Work ILIKE QRY_Timesheet.TYPEOFWORK
  LEFT OUTER JOIN {{ ref('BRONZE__TEH_FINANCE__MDM_EMPLOYEE_ADP_CODE_MAPPING') }} MDM_ADP_Code_Mapping ON MDM_ADP_Code_Mapping.ADP_Code = QRY_Timesheet.HOME_ADP_CO
  LEFT OUTER JOIN {{ ref('BRONZE__TEH_FINANCE__MDM_KRONOS_SHIFT_TABLE') }} Kronos_Shift_Table ON QRY_Timesheet.WORKRULENAME =  Kronos_Shift_Table.Work_Rule_Name
  LEFT OUTER JOIN {{ ref('BRONZE__TEH_FINANCE__TEACOMMON_EMPLOYEE') }} TEA_Common_Employee ON TEA_Common_Employee.EMPLOYEEID = QRY_Timesheet.PERSONNUM
  LEFT OUTER JOIN {{ ref('BRONZE__TEH_FINANCE__MDM_SEGMENTMAPPING') }} SegmentMapping ON SegmentMapping.SegmentCode =  QRY_Timesheet.HOME_DIM2
  LEFT OUTER JOIN SAP_SEGMENT on SAP_CODE = QRY_Timesheet.HOME_DIM2
  LEFT OUTER JOIN {{ ref('BRONZE__TEH_FINANCE__MDM_TASTASK') }} TASTask ON TASTask.Task_Name ilike QRY_Timesheet.TASK
  LEFT OUTER JOIN {{ ref('BRONZE__TEH_FINANCE__SHAREPOINT_SERVICE_BUSINESS_UNIT_MAPPING') }} MachineBU ON MachineBU.BU_SOURCE_KEY = QRY_Timesheet.THREE
  LEFT OUTER JOIN {{ ref('BRONZE__TEH_FINANCE__SHAREPOINT_SERVICE_BUSINESS_UNIT_MAPPING') }} BUMAP ON QRY_Timesheet.COSTCENTER = BUMAP.BU_SOURCE_KEY   --ADDED 3/13/24
  LEFT OUTER JOIN HISTORY ON HISTORY.EMPID_SNAPSHOT = QRY_Timesheet.PERSONNUM||'_'||LEFT(QRY_Timesheet.EVENTDATE,7)  --ADDED 3/18/24
  LEFT OUTER JOIN {{ ref('SILVER__TEH_FINANCE__GLOBAL_MACHINES') }} WisdomMachine on WisdomMachine.SERIAL_NUMBER = QRY_Timesheet.MACHINESN
), -- end of combined kronos data

source_data as
(
    select
    kronos_data.ADPCOMPANY,
    kronos_data.APPROVINGSUPERVISORID,
    kronos_data.BUCODE,
    kronos_data.BILLABLECATEGORY,
    kronos_data.COMMENT,
    kronos_data.DEPARTMENTID,
    kronos_data.EMPBUNAME,
    kronos_data.EMPLOYEEFULLNAME,
    kronos_data.EMPLOYEEID,
    kronos_data.EMPLOYEETYPE,
    kronos_data.ENDTIMESTAMP,
    kronos_data.ENTEREDONTIMESTAMP,
    kronos_data.EVENTDATE,
    kronos_data.EVENTTIMESTAMP,
    CASE WHEN LEFT(kronos_data.FABCODE,1) IN ('B','D') then crm_account.NAME else kronos_data.FAB end as FAB,
    kronos_data.FABCODE,
    kronos_data.HOURSCHARGED,
    kronos_data.ISEMPLOYEEAPPROVED,
    kronos_data.MACHINEBU,
    kronos_data.MACHINESERIALNUMBER,
    kronos_data.NOTES,
    kronos_data.OTCOMMENT,
    kronos_data.OFFICEID,
    kronos_data.ORGMAPTYPE,
    kronos_data.ORGPATHTEXT,
    kronos_data.PAYCODENAME,
    kronos_data.PRODUCTSUBCATEGORY,
    kronos_data.PRODUCTTYPE,
    kronos_data.PROJECTCOMPANY,
    kronos_data.PROJECTGROUP,
    kronos_data.PROJECTSUBGROUP,
    kronos_data.PROJECTTASK,
    kronos_data.PROJECTTYPEOFWORK,
    kronos_data.SERVICEORDER,
    kronos_data.SHIFTNUMBER,
    kronos_data.SHIFTTYPE,
    kronos_data.SOURCESYSTEM,
    kronos_data.STARTTIMESTAMP,
    kronos_data.TASK,
    kronos_data.TASKSOURCE,
    kronos_data.TASKWRENCHTYPE,
    kronos_data.TIMEINSECONDS,
    kronos_data.TIMEPUNCHID,
    kronos_data.TIMESHEETITEMID,
    kronos_data.TYPEOFWORK,
    kronos_data.TYPEOFWORKGROUP,
    kronos_data.TYPEOFWORKSOURCE,
    kronos_data.WORKRULENAME,
    kronos_data.SAPOPERATION,
    COALESCE(kronos_data.CRMWORKORDER,wo_msdyn_timeentry.WO_WORKORDERNONAME) AS CRMWORKORDER,
    wo_msdyn_timeentry.TEL_WO_CATEGORYNAME,
    wo_msdyn_timeentry.TEL_WO_BU2NAME,
    wo_msdyn_timeentry.WO_REGIONNAME,
    wo_msdyn_timeentry.WO_TASK2NAME,
    wo_msdyn_timeentry.TEL_WO_TYPEOFPAYMENT,
    wo_msdyn_timeentry.WO_TIMECATEGORY,
	  kronos_data.EMPCOSTCENTER,  --ADDED 3/13/24
	  kronos_data.EMPSERVICEBUGROUP,   --ADDED 3/13/24
    '{{ invocation_id }}' AS AUDIT_LOG_ID
  from kronos_data
  left join crm_account on crm_account.ACCOUNTNUMBER = kronos_data.FABCODE
  left join wo_msdyn_timeentry on upper(wo_msdyn_timeentry.ID) = kronos_data.TIMEPUNCHID
),

transform_data as (
  select
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') AS _ROW_HASH,
    ADPCOMPANY,
    APPROVINGSUPERVISORID,
    BUCODE,
    BILLABLECATEGORY,
    COMMENT,
    DEPARTMENTID,
    EMPBUNAME,
    EMPLOYEEFULLNAME,
    EMPLOYEEID,
    EMPLOYEETYPE,
    ENDTIMESTAMP,
    ENTEREDONTIMESTAMP,
    EVENTDATE,
    EVENTTIMESTAMP,
    FAB,
    FABCODE,
    HOURSCHARGED,
    ISEMPLOYEEAPPROVED,
    MACHINEBU,
    MACHINESERIALNUMBER,
    NOTES,
    OTCOMMENT,
    OFFICEID,
    ORGMAPTYPE,
    ORGPATHTEXT,
    PAYCODENAME,
    PRODUCTSUBCATEGORY,
    PRODUCTTYPE,
    PROJECTCOMPANY,
    PROJECTGROUP,
    PROJECTSUBGROUP,
    PROJECTTASK,
    PROJECTTYPEOFWORK,
    SERVICEORDER,
    SHIFTNUMBER,
    SHIFTTYPE,
    SOURCESYSTEM,
    STARTTIMESTAMP,
    TASK,
    TASKSOURCE,
    TASKWRENCHTYPE,
    TIMEINSECONDS,
    TIMEPUNCHID,
    TIMESHEETITEMID,
    TYPEOFWORK,
    TYPEOFWORKGROUP,
    TYPEOFWORKSOURCE,
    WORKRULENAME,
    SAPOPERATION,
    CRMWORKORDER,
    TEL_WO_CATEGORYNAME,
    TEL_WO_BU2NAME,
    WO_REGIONNAME,
    WO_TASK2NAME,
    TEL_WO_TYPEOFPAYMENT,
    WO_TIMECATEGORY,
	  EMPCOSTCENTER,  --ADDED 3/13/24
	  EMPSERVICEBUGROUP  --ADDED 3/13/24
  from source_data
)

,type_data as (
    SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        ADPCOMPANY,
        APPROVINGSUPERVISORID,
        BUCODE,
        BILLABLECATEGORY,
        COMMENT,
        DEPARTMENTID,
        EMPBUNAME,
        EMPLOYEEFULLNAME,
        EMPLOYEEID,
        EMPLOYEETYPE,
        ENDTIMESTAMP,
        ENTEREDONTIMESTAMP,
        EVENTDATE,
        EVENTTIMESTAMP,
        FAB,
        FABCODE,
        HOURSCHARGED,
        ISEMPLOYEEAPPROVED,
        MACHINEBU,
        MACHINESERIALNUMBER,
        NOTES,
        OTCOMMENT,
        OFFICEID,
        ORGMAPTYPE,
        ORGPATHTEXT,
        PAYCODENAME,
        PRODUCTSUBCATEGORY,
        PRODUCTTYPE,
        PROJECTCOMPANY,
        PROJECTGROUP,
        PROJECTSUBGROUP,
        PROJECTTASK,
        PROJECTTYPEOFWORK,
        SERVICEORDER,
        SHIFTNUMBER,
        SHIFTTYPE,
        SOURCESYSTEM,
        STARTTIMESTAMP,
        TASK,
        TASKSOURCE,
        TASKWRENCHTYPE,
        TIMEINSECONDS,
        TIMEPUNCHID,
        TIMESHEETITEMID,
        TYPEOFWORK,
        TYPEOFWORKGROUP,
        TYPEOFWORKSOURCE,
        WORKRULENAME,
        SAPOPERATION,
        CRMWORKORDER,
        TEL_WO_CATEGORYNAME,
        TEL_WO_BU2NAME,
        WO_REGIONNAME,
        WO_TASK2NAME,
        TEL_WO_TYPEOFPAYMENT,
        WO_TIMECATEGORY,
        EMPCOSTCENTER,  --ADDED 3/13/24
        EMPSERVICEBUGROUP  --ADDED 3/13/24
    FROM transform_data
)

SELECT * from type_data

