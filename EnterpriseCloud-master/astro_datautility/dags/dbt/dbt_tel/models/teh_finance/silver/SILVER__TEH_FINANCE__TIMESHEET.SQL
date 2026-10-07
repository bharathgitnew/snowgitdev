{{ config(
    alias='TIMESHEET',
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    tags=['kronos'],
) }}


with WISDOM as (
	SELECT
		MAC_MAIN_MAC_SN AS Serial_Number, 
		MAC_MAIN_SWLH_SYSTEM_NAME,
		MAC_MAIN_MAC_NICKNAME
	FROM {{ ref('SILVER__TEH_FINANCE__WISDOM_MACHINE_DETAILS') }}
	QUALIFY (ROW_NUMBER() OVER (PARTITION BY MAC_MAIN_MAC_SN  ORDER BY WISDOM_MACHINE_DETAILS.MAC_MAIN_HISTORY  DESC )) = 1
),

SAPCONTRACT AS (
	SELECT DISTINCT 
		CRM.TEL_WO_SERVICEORDERNO_3200, 
		SOBL.VBAK_CONTRACT_NUMBER
	FROM {{ ref('BRONZE__TEH_FINANCE__CRM_FILE_MSDYN_WORKORDER') }}   CRM
	INNER JOIN {{ ref('SILVER__TEH_FINANCE__SALES_ORDER_BILLING_LINE') }}   SOBL
	ON SOBL.VBAK_SALES_DOCUMENT = CRM.TEL_WO_PRIMARY_SONAME
	WHERE CRM.TEL_WO_SERVICEORDERNO_3200 IS NOT NULL
	AND VBAK_SALES_ORGANIZATION = '3200'
	AND VBAK_SALES_DOCUMENT_TYPE = 'ZS10'
	AND LEFT(VBAK_CONTRACT_NUMBER,1) = 'T'
),

FSTEMPLOYEEGROUP AS (
    SELECT
        FSTSUPERVISORID
        ,FSTEMPLOYEEGROUP
    FROM {{ ref('BRONZE__TEH_FINANCE__FILE_FST_EMPLOYEE_GROUP') }}
),
COSTCENTER AS (
	SELECT 
		COST_CENTER_CODE,
		COST_CENTER_NAME,
		COMPANY_CODE
	FROM {{ ref('SILVER__TEH_FINANCE__COST_CENTER') }}
),
source_data AS
(
	SELECT
		CASE
			WHEN Timesheet.BUCode IN ('5999','33') THEN 'FST'
			WHEN Timesheet.DepartmentId IN ('7600', '7601', '053', '054') Then 'Tech Support'
			ELSE 'Other'
		END AS FSTEMPLOYEEGROUP,
		Timesheet.EmpBUName,
		ApprovingSupervisor.Full_Name  AS ApprovingSupervisor ,
		IFNULL(ThisEmployee.Full_Name,Timesheet.EmployeeFullName) AS EmployeeFullName,
		Timesheet.EmployeeId,
		EventDate.Year_Month_Text,
		Timesheet.EventDate,
		Timesheet.HoursCharged,
		Timesheet.PaycodeName,
		Timesheet.OrgMapType,
		Timesheet.MachineBU,
		Timesheet.Fab,
		Timesheet.MachineSerialNumber,
		COALESCE(Wisdom.MAC_MAIN_SWLH_SYSTEM_NAME,Machine.Object) AS Model,
		Wisdom.MAC_MAIN_MAC_NICKNAME AS CustomerToolId,
		Timesheet.TypeOfWorkGroup,
		Timesheet.TypeOfWork,
		Timesheet.BillableCategory,
		Timesheet.TaskWrenchType,
		Timesheet.Task,
		Timesheet.ServiceOrder,
		COALESCE(ServiceOrder.Contract_No,SAPCONTRACT.VBAK_CONTRACT_NUMBER) AS Contract,
		Timesheet.ProjectCompany,
		Timesheet.ProjectGroup,
		Timesheet.ProjectSubGroup,
		Timesheet.ProjectTypeOfWork,
		Timesheet.ProjectTask,
		Timesheet.StartTimestamp AS StartDateTimestamp,
		Timesheet.EndTimestamp AS EndDateTimestamp,
		Timesheet.EnteredOnTimestamp AS EnteredOnTimestamp,
		Timesheet.Comment,
		Timesheet.OTComment,
		Timesheet.Notes,
		Supervisor.Full_Name  AS CurrentSupervisor,
		ThisEmployeeJobMapping.Job_Category AS EmployeeJobCategory,
		EmployeeOffice.OfficeName AS EmployeeOfficeName,
		Timesheet.WorkRuleName,
		Timesheet.ShiftType,
		Timesheet.ShiftNumber,
		MDMOffice.Region AS CustomerRegion,
		customer_mapping.CUSTOMER_GROUP AS CustomerGroup,
		UPPER(customer_mapping.CUSTOMER_NAME) AS CustomerName,  
		Timesheet.FabCode AS FabCode,
		COALESCE(Fab.ServiceCenterOfficeId,LEGACY_OFFICE_CODE) AS FabOfficeCode,
		COALESCE(FabOffice.OfficeName,LEGACY_OFFICE) AS FabOfficeName,
		EventDate.Pay_Period_End_Date AS PayperiodEndDate,
		EventDate.Year_Work_Week_Text AS WorkWeekYYYYWW,
		Timesheet.DepartmentId AS EmployeeDepartmentId,
		Timesheet.BUCode AS EmployeeBUCode,
		Timesheet.OfficeId AS EmployeeOfficeId,
		Timesheet.ADPCompany,
		ThisEmployee.Employee_Type_FST EmployeeType,
		Timesheet.ApprovingSupervisorId,
		ThisEmployee.Supervisor_Employee_Id AS CurrentSupervisorId,
		Timesheet.SourceSystem AS SourceSystem,
		Timesheet.TimeSheetItemId AS TimesheetId,
		EventDate.Fiscal_Year_Text FiscalYear,
		Timesheet.TypeOfWorkSource AS TypeOfWorkSource,
		Timesheet.ProductType as ProductType,
		Timesheet.TEL_WO_CATEGORYNAME,
		Timesheet.TEL_WO_BU2NAME,
		Timesheet.WO_REGIONNAME,
		Timesheet.WO_TASK2NAME,
		Timesheet.TEL_WO_TYPEOFPAYMENT,
		Timesheet.WO_TIMECATEGORY,
		Timesheet.SAPOPERATION,
		Timesheet.CRMWORKORDER,
		Timesheet.EMPCOSTCENTER,--ADDED 3/13/24
		COSTCENTER.COST_CENTER_NAME,  --ADDED Cost Center name from Request : Kanbanize 35022
        Timesheet.EMPSERVICEBUGROUP
	FROM {{ ref('SILVER__TEH_FINANCE__KRONOS_TIMESHEET') }} Timesheet

	JOIN {{ source('STATIC_OBJECTS', 'CALENDAR_DATE') }}  EventDate
	ON EventDate.Calendar_Date = Timesheet.EventDate
	
	LEFT OUTER JOIN {{ ref('SILVER__TEH_FINANCE__EMPLOYEE') }}  CommonEmployee
	ON CommonEmployee.EmployeeId = Timesheet.EmployeeId

	LEFT OUTER JOIN {{ ref('SILVER__TEH_FINANCE__GLOBAL_EMPLOYEE') }}    ThisEmployee
	ON ThisEmployee.Employee_Id = Timesheet.EmployeeId

	LEFT OUTER JOIN {{ ref('SILVER__TEH_FINANCE__FAB') }} Fab                                       
	ON Fab.FabId = Timesheet.Fab

	LEFT OUTER JOIN {{ ref('SILVER__TEH_FINANCE__SERVICE_B_CODE_MAPPING') }}  B
	ON B.B_CODE = Timesheet.FABCODE

	left join {{ ref('SILVER__TEH_FINANCE__CUSTOMER_MAPPING') }} as customer_mapping
		on customer_mapping.CUSTOMER_CODE in (Timesheet.FABCODE, left(Timesheet.FABCODE, 5))

	LEFT OUTER JOIN WISDOM ON Wisdom.Serial_Number = Timesheet.MachineSerialNumber

	LEFT OUTER JOIN SAPCONTRACT ON SAPCONTRACT.TEL_WO_SERVICEORDERNO_3200 = Timesheet.ServiceOrder

	LEft OUTER JOIN {{ ref('BRONZE__TEH_FINANCE__MDM_EMPLOYEES_JOB_TITLE_MAPPING') }} ThisEmployeeJobMapping
	ON ThisEmployeeJobMapping.TEA_COMMON_JOB_TITLE = CommonEmployee.JobTitle

	LEFT OUTER JOIN {{ ref('SILVER__TEH_FINANCE__GLOBAL_EMPLOYEE') }}  Supervisor                        
	ON Supervisor.Employee_Id = ThisEmployee.Supervisor_Employee_Id

	LEFT OUTER JOIN  {{ ref('SILVER__TEH_FINANCE__GLOBAL_EMPLOYEE') }}  ApprovingSupervisor                         
	ON ApprovingSupervisor.Employee_Id = Timesheet.ApprovingSupervisorId

	LEFT OUTER JOIN {{ ref('SILVER__TEH_FINANCE__BAAN_OFFICE') }} FabOffice                                     
	ON FabOffice.OfficeId = Fab.ServiceCenterOfficeId AND FabOffice.IsDefault = 'Yes'

	LEFT OUTER JOIN {{ ref('SILVER__TEH_FINANCE__BAAN_OFFICE') }} EmployeeOffice                                 
	ON EmployeeOffice.OfficeId = Timesheet.OfficeID AND EmployeeOffice.CompanyID = 201

	LEFT OUTER JOIN {{ ref('SILVER__TEH_FINANCE__MDM_OFFICE') }}  MDMOffice                                   
	ON MDMOffice.OfficeCode = FabOffice.OfficeId

	LEFT OUTER JOIN {{ ref('SILVER__TEH_FINANCE__SERVICEORDER_DISTINCT') }}   ServiceOrder                      
	ON ServiceOrder.SERVICE_ORDER_NO = Timesheet.ServiceOrder

	LEFT OUTER JOIN {{ ref('SILVER__TEH_FINANCE__MACHINE_DISTINCT') }}   Machine                          
	ON Machine.SerialNumber = Timesheet.MachineSerialNumber

	LEFT OUTER JOIN FSTEMPLOYEEGROUP 
	ON FSTEMPLOYEEGROUP.FSTSUPERVISORID = CommonEmployee.SupervisorId

	LEFT OUTER JOIN COSTCENTER 
	ON COSTCENTER.COST_CENTER_CODE = Timesheet.EMPCOSTCENTER 

	WHERE EventDate.Fiscal_Year_Number >= 2014
),

transform_data as (
	select 
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		FSTEMPLOYEEGROUP,
		EMPBUNAME,
		APPROVINGSUPERVISOR,
		EMPLOYEEFULLNAME,
		EMPLOYEEID,
		YEAR_MONTH_TEXT,
		EVENTDATE,
		HOURSCHARGED,
		PAYCODENAME,
		ORGMAPTYPE,
		MACHINEBU,
		FAB,
		MACHINESERIALNUMBER,
		MODEL,
		CUSTOMERTOOLID,
		TYPEOFWORKGROUP,
		TYPEOFWORK,
		BILLABLECATEGORY,
		TASKWRENCHTYPE,
		TASK,
		SERVICEORDER,
		CONTRACT,
		PROJECTCOMPANY,
		PROJECTGROUP,
		PROJECTSUBGROUP,
		PROJECTTYPEOFWORK,
		PROJECTTASK,
		STARTDATETIMESTAMP,
		ENDDATETIMESTAMP,
		ENTEREDONTIMESTAMP,
		COMMENT,
		OTCOMMENT,
		NOTES,
		CURRENTSUPERVISOR,
		EMPLOYEEJOBCATEGORY,
		EMPLOYEEOFFICENAME,
		WORKRULENAME,
		SHIFTTYPE,
		SHIFTNUMBER,
		CUSTOMERREGION,
		CUSTOMERGROUP,
		CUSTOMERNAME,
		FABCODE,
		FABOFFICECODE,
		FABOFFICENAME,
		PAYPERIODENDDATE,
		WORKWEEKYYYYWW,
		EMPLOYEEDEPARTMENTID,
		EMPLOYEEBUCODE,
		EMPLOYEEOFFICEID,
		ADPCOMPANY,
		EMPLOYEETYPE,
		APPROVINGSUPERVISORID,
		CURRENTSUPERVISORID,
		SOURCESYSTEM,
		TIMESHEETID,
		FISCALYEAR,
		TYPEOFWORKSOURCE,
		PRODUCTTYPE,
		TEL_WO_CATEGORYNAME,
		TEL_WO_BU2NAME,
		WO_REGIONNAME,
		WO_TASK2NAME,
		TEL_WO_TYPEOFPAYMENT,
		WO_TIMECATEGORY,
		SAPOPERATION,
		CRMWORKORDER,
		EMPCOSTCENTER, --ADDED 3/13/24
		COST_CENTER_NAME, --ADDED Cost Center name from Request : Kanbanize 35022
        EMPSERVICEBUGROUP 
	from source_data
),

type_data as (
	select 
		_AUDIT_LOG_ID,
        _ROW_HASH,
		FSTEMPLOYEEGROUP,
		EMPBUNAME,
		APPROVINGSUPERVISOR,
		EMPLOYEEFULLNAME,
		EMPLOYEEID,
		YEAR_MONTH_TEXT,
		EVENTDATE,
		HOURSCHARGED,
		PAYCODENAME,
		ORGMAPTYPE,
		MACHINEBU,
		FAB,
		MACHINESERIALNUMBER,
		MODEL,
		CUSTOMERTOOLID,
		TYPEOFWORKGROUP,
		TYPEOFWORK,
		BILLABLECATEGORY,
		TASKWRENCHTYPE,
		TASK,
		SERVICEORDER,
		CONTRACT,
		PROJECTCOMPANY,
		PROJECTGROUP,
		PROJECTSUBGROUP,
		PROJECTTYPEOFWORK,
		PROJECTTASK,
		STARTDATETIMESTAMP,
		ENDDATETIMESTAMP,
		ENTEREDONTIMESTAMP,
		COMMENT,
		OTCOMMENT,
		NOTES,
		CURRENTSUPERVISOR,
		EMPLOYEEJOBCATEGORY,
		EMPLOYEEOFFICENAME,
		WORKRULENAME,
		SHIFTTYPE,
		SHIFTNUMBER,
		CUSTOMERREGION,
		CUSTOMERGROUP,
		CUSTOMERNAME,
		FABCODE,
		FABOFFICECODE,
		FABOFFICENAME,
		PAYPERIODENDDATE,
		WORKWEEKYYYYWW,
		EMPLOYEEDEPARTMENTID,
		EMPLOYEEBUCODE,
		EMPLOYEEOFFICEID,
		ADPCOMPANY,
		EMPLOYEETYPE,
		APPROVINGSUPERVISORID,
		CURRENTSUPERVISORID,
		SOURCESYSTEM,
		TIMESHEETID,
		FISCALYEAR,
		TYPEOFWORKSOURCE,
		PRODUCTTYPE,
		TEL_WO_CATEGORYNAME,
		TEL_WO_BU2NAME,
		WO_REGIONNAME,
		WO_TASK2NAME,
		TEL_WO_TYPEOFPAYMENT,
		WO_TIMECATEGORY,
		SAPOPERATION,
		CRMWORKORDER,
		EMPCOSTCENTER, --ADDED 3/13/24
		COST_CENTER_NAME, --ADDED Cost Center name from Request : Kanbanize 35022
        EMPSERVICEBUGROUP 
	from transform_data
)

select * from transform_data

