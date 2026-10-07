{{ config(
      alias='TIMESHEET',
      materialized = 'tel_incremental',
      incremental_strategy = 'insert_overwrite',
) }}


with WISDOM as (
	SELECT
		MAC_MAIN_MAC_SN AS Serial_Number, 
		MAC_MAIN_SWLH_SYSTEM_NAME,
		MAC_MAIN_MAC_NICKNAME
	FROM {{ ref('SILVER__TEA_SERVICE__WISDOM_MACHINE_DETAILS') }}
	QUALIFY (ROW_NUMBER() OVER (PARTITION BY MAC_MAIN_MAC_SN  ORDER BY WISDOM_MACHINE_DETAILS.MAC_MAIN_HISTORY  DESC )) = 1
),

SAPCUSTOMER AS (
	SELECT DISTINCT
		BUSINESS_PARTNER_NUMBER
		,NAME_1_OF_ORGANIZATION AS CUSTOMER
		,CASE
		WHEN CORPORATION IN ('AA2000300','AA4604900','AA4712300','AA2026100','AA2020100','AA4337600','AA3068700') THEN 'GF/IBM/Albany'
		WHEN CORPORATION IN ('AA4690800', 'AA2030100', 'AA2030200', 'AA2030700', 'AA2031700') THEN 'Intel'
		WHEN CORPORATION IN ('AA4415000','AA3435600') THEN 'Micron'
		WHEN CORPORATION IN ('AA2130100') THEN 'TI'
		WHEN CORPORATION IN ('AA2120300') THEN 'Samsung'
		WHEN CORPORATION IN ('A00000870') THEN 'TSMC'
		WHEN CORPORATION IN ('AA0013900','AA0013600','AA0012300','AA0010100','AA0000200','AA0010300','AA0000900','AA0011400','AA0010200','AA0000600',
		'AA0000100','AA0002100','AA0013300','AA0010500','AA0000500','AA0012100','AA0012000') THEN 'TEL Group'
		ELSE 'Regional'
		END AS CUSTOMERGROUP
	FROM {{ ref('SILVER__TEA_SERVICE__BUSINESS_PARTNERS_GENERAL_DATA') }} 
	WHERE LEFT(BUSINESS_PARTNER_NUMBER,1) IN ('B', 'D')
),

SAPCONTRACT AS (
	SELECT DISTINCT 
		CRM.TEL_WO_SERVICEORDERNO_3200, 
		SOBL.VBAK_CONTRACT_NUMBER
	FROM {{ ref('BRONZE__TEA_SERVICE__CRM_FILE_MSDYN_WORKORDER') }}   CRM
	INNER JOIN {{ ref('SILVER__TEA_SERVICE__SALES_ORDER_BILLING_LINE') }}   SOBL
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
    FROM {{ ref('BRONZE__TEA_SERVICE__FILE_FST_EMPLOYEE_GROUP') }}
),
COSTCENTER AS (
	SELECT 
		COST_CENTER_CODE,
		COST_CENTER_NAME,
		COMPANY_CODE
	FROM {{ ref('SILVER__TEA_SERVICE__COST_CENTER') }}
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
		CASE
			WHEN Customer.SalesGroupName = 'NXP/TI' AND Customer.CustomerName ILIKE 'TEXAS INSTRUMENTS%' THEN 'TI'
			WHEN Customer.SalesGroupName = 'NXP/TI' AND Customer.CustomerName ILIKE 'NXP%' THEN 'Regional'
			ELSE COALESCE(Customer.SalesGroupName,SAPCUSTOMER.CUSTOMERGROUP)
		END AS CustomerGroup,
		UPPER(COALESCE(Customer.CustomerName,SAPCUSTOMER.CUSTOMER)) AS CustomerName,  
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
	FROM {{ ref('SILVER__TEA_SERVICE__KRONOS_TIMESHEET') }} Timesheet

	JOIN {{ source('STATIC_OBJECTS', 'CALENDAR_DATE') }}  EventDate
	ON EventDate.Calendar_Date = Timesheet.EventDate
	
	LEFT OUTER JOIN {{ ref('SILVER__TEA_SERVICE__EMPLOYEE') }}  CommonEmployee
	ON CommonEmployee.EmployeeId = Timesheet.EmployeeId

	LEFT OUTER JOIN {{ ref('SILVER__TEA_SERVICE__GLOBAL_EMPLOYEE') }}    ThisEmployee
	ON ThisEmployee.Employee_Id = Timesheet.EmployeeId

	LEFT OUTER JOIN {{ ref('SILVER__TEA_SERVICE__FAB') }} Fab                                       
	ON Fab.FabId = Timesheet.Fab

	LEFT OUTER JOIN {{ ref('SILVER__TEA_SERVICE__SERVICE_B_CODE_MAPPING') }}  B
	ON B.B_CODE = Timesheet.FABCODE

	LEFT OUTER JOIN {{ ref('SILVER__TEA_SERVICE__CUSTOMER') }}  Customer                                        
	ON Customer.CustomerId =LEFT(Timesheet.FabCode,5)

	LEFT OUTER JOIN WISDOM ON Wisdom.Serial_Number = Timesheet.MachineSerialNumber

	LEFT OUTER JOIN SAPCUSTOMER ON SAPCUSTOMER.BUSINESS_PARTNER_NUMBER = Timesheet.FABCODE

	LEFT OUTER JOIN SAPCONTRACT ON SAPCONTRACT.TEL_WO_SERVICEORDERNO_3200 = Timesheet.ServiceOrder

	LEft OUTER JOIN {{ ref('BRONZE__TEA_SERVICE__MDM_EMPLOYEES_JOB_TITLE_MAPPING') }} ThisEmployeeJobMapping
	ON ThisEmployeeJobMapping.TEA_COMMON_JOB_TITLE = CommonEmployee.JobTitle

	LEFT OUTER JOIN {{ ref('SILVER__TEA_SERVICE__GLOBAL_EMPLOYEE') }}  Supervisor                        
	ON Supervisor.Employee_Id = ThisEmployee.Supervisor_Employee_Id

	LEFT OUTER JOIN  {{ ref('SILVER__TEA_SERVICE__GLOBAL_EMPLOYEE') }}  ApprovingSupervisor                         
	ON ApprovingSupervisor.Employee_Id = Timesheet.ApprovingSupervisorId

	LEFT OUTER JOIN {{ ref('SILVER__TEA_SERVICE__BAAN_OFFICE') }} FabOffice                                     
	ON FabOffice.OfficeId = Fab.ServiceCenterOfficeId AND FabOffice.IsDefault = 'Yes'

	LEFT OUTER JOIN {{ ref('SILVER__TEA_SERVICE__BAAN_OFFICE') }} EmployeeOffice                                 
	ON EmployeeOffice.OfficeId = Timesheet.OfficeID AND EmployeeOffice.CompanyID = 201

	LEFT OUTER JOIN {{ ref('SILVER__TEA_SERVICE__MDM_OFFICE') }}  MDMOffice                                   
	ON MDMOffice.OfficeCode = FabOffice.OfficeId

	LEFT OUTER JOIN {{ ref('SILVER__TEA_SERVICE__SERVICEORDER_DISTINCT') }}   ServiceOrder                      
	ON ServiceOrder.SERVICE_ORDER_NO = Timesheet.ServiceOrder

	LEFT OUTER JOIN {{ ref('SILVER__TEA_SERVICE__MACHINE_DISTINCT') }}   Machine                          
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