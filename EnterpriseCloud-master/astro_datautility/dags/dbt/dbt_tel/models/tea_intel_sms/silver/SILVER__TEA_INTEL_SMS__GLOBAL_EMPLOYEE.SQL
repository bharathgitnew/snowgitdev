{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='SHARED_DATASETS_Global_Employee',
    unique_key = ['EMPLOYEE_ID']
) }}

with source_data_Workday as
(
	SELECT
		*
	FROM {{ ref('BRONZE__TEA_INTEL_SMS__MYSKILLS_WORKDAYEMPLOYEE') }}
)
, source_data_TEACommon as
(
	SELECT
		*
	FROM {{ ref('SILVER__TEA_INTEL_SMS__EMPLOYEE') }}
    WHERE TRY_TO_NUMBER(EmployeeId) IS NOT NULL
)
, source_data_AD as
(
	SELECT
		*
	FROM {{ ref('BRONZE__TEA_INTEL_SMS__ACTIVEDIRECTORY_USERLIST') }}
    WHERE TRY_TO_NUMBER(MailNickname) IS NOT NULL
	QUALIFY ROW_NUMBER() OVER (PARTITION BY MailNickname order by _FILEDATE desc, userid desc)=1  --Added this code as  AD has multiple records for same MailNickname and there is no way to define which one is correct
)
, security__company_grouping as
(
    SELECT * FROM {{ source('STATIC_OBJECTS', 'COMPANYGROUPING') }}
)
, mdm__employee_type as
(
    SELECT * FROM {{ ref('BRONZE__TEA_INTEL_SMS__MDM_EMPLOYEE_TYPE') }}
)
, mdm__manager_employee_group as
(
    SELECT * FROM {{ ref('BRONZE__TEA_INTEL_SMS__MDM_MANAGER_EMPLOYEE_GROUP') }}
)
,supervisor_details as 
(
    SELECT 
        Employee_Id AS EMPLOYEE_ID,
        Full_Name AS SUPERVISOR_NAME
    FROM {{ this }}
)   

,transform_data as
(
	SELECT
        DISTINCT
		 COALESCE(TEACommon.EmployeeId, AD.MailNickname,Workday.EmployeeId) AS Employee_Id
        ,COALESCE(TEACommon.FullName, AD.Surname || ', ' || AD.GivenName,Workday.EmployeeName ) AS Full_Name
        ,COALESCE(TEACommon.FirstName, AD.GivenName ,Workday.FirstNameEN) AS First_Name
        ,COALESCE(TEACommon.LastName, AD.Surname,Workday.LastNameEN ) AS Last_Name
        ,LOWER(COALESCE(TEACommon.Email, AD.UserPrincipalName ) ) AS EmailAddress
        ,COALESCE(TEACommon.SupervisorID,Workday.SupervisorEmployeeNumber) AS Supervisor_Employee_Id
        ,SUPERVISOR.SUPERVISOR_NAME
        ,COALESCE(TEACommon.Seniority_Date,Workday.SeniorityDate ) AS Seniority_Date
        ,COALESCE(TEACommon.DateHire,Workday.OriginalHireDate) AS Hire_Date
        ,TEACommon.RehireDate AS Rehire_Date
        ,TEACommon.DateTerm AS Termination_Date
        ,TEACommon.SalaryExempt AS Salary_Type
        ,CASE
            WHEN TEACommon.Active = 'true'        THEN 'Active'
            WHEN TEACommon.Active = 'false'       THEN 'Inactive'
            WHEN AD.AccountEnabled = 'true'       THEN 'Active'
            WHEN AD.AccountEnabled = 'false'      THEN 'Inactive'
            WHEN Workday.EmployeeStatusCode = '3' THEN 'Active'
            WHEN Workday.EmployeeStatusCode = '1' THEN 'OnLeave'
            WHEN Workday.EmployeeStatusCode = '0' THEN 'Inactive'
            ELSE 'Unknown'
         END AS Employee_Status
        ,DECODE(Workday.ExpatInfo,'0','No', '1','Yes', 'Unknown') AS Is_Expat
        ,DECODE(TEACommon.isManager,'false','No', 'true','Yes', 'Unknown') AS Is_Manager
        ,TEACommon.ProdLineCode AS Business_Unit

        ,Workday.CompanyCode AS Company_Id
        ,COALESCE(TEACommon.DeptCode,Workday.DepartmentGroupCode) AS Department_Id
        ,COALESCE(TEACommon.LocationCode,Workday.WorkLocationCode) AS Office_Id

        ,COALESCE(TEACommon.JobTitle,Workday.BusinessTitle) AS Job_Title
        ,Workday.JobFamilyNameEN AS Job_Family_GroupName

        ,COALESCE(TO_VARCHAR(TEACommon.EmployeeType),'Unknown',Workday.EmployeeTypeCode) AS Employee_Type_Code
        ,EmployeeType_TEACommon.Name AS Employee_Type
        ,COALESCE(EmployeeType_TEACommon.NameFST,EmployeeType_Workday.NameFST) AS Employee_Type_FST

        ,CASE
            WHEN TeaCommon.FSTEmployeeGroup IS NOT NULL THEN TeaCommon.FSTEmployeeGroup
            WHEN MDM_SupervisorGrouping.GroupName IS NOT NULL THEN MDM_SupervisorGrouping.GroupName
            WHEN TEACommon.PRODLINECODE = '5999' THEN 'Other - FST'
            WHEN TEACommon.PRODLINECODE = '7000' THEN 'Tech Support'
            WHEN TEACommon.PRODLINECODE = '7001' THEN 'Tech Support'
            ELSE 'Non-FST'
         END AS Group_Name_FST

        ,AD.UserId AS ActiveDirectoryId
        ,AD.DisplayName AS ActiveDirectoryDisplayName
        ,CASE WHEN Workday.EmployeeID IS NOT NULL THEN 'Yes' ELSE 'No' END AS Is_In_Workday
		,CASE WHEN TEACommon.EmployeeID IS NOT NULL THEN 'Yes' ELSE 'No' END AS Is_In_TEACommon
		,CASE WHEN AD.MailNickname IS NOT NULL THEN 'Yes' ELSE 'No' END AS Is_In_ActiveDirectory
        ,COALESCE(SecGroup.HRRegion, 'Unknown' ) AS Company_HR_Region
        ,UPPER(COALESCE(TEACommon.Email, AD.UserPrincipalName)) AS Security_UserId
        ,CASE WHEN HomeCompany.IS_USA_COMPANY = 'Yes' AND HostCompany.IS_USA_COMPANY = 'Yes' THEN 'Regular' WHEN HomeCompany.IS_USA_COMPANY = 'Yes' AND HostCompany.IS_USA_COMPANY = 'No' THEN 'Expat' WHEN HomeCompany.IS_USA_COMPANY = 'No' AND HostCompany.IS_USA_COMPANY = 'Yes' THEN 'Inpat' ELSE 'Foreign' END AS US_REGION_STATUS
        ,CASE WHEN IS_MANAGER = 'true' THEN 'Yes' WHEN IS_MANAGER = 'false' THEN 'No' ELSE 'Unknown' END AS IS_MANAGER_FLAG
        ,WORKERCOMPANYLIST.HOMECOMPANYID AS Current_Home_Company_Id
        ,WORKERCOMPANYLIST.HOMEDEPARTMENTID AS Current_Home_Department_Id
        ,WORKERCOMPANYLIST.HOSTCOMPANYID AS Current_Host_Company_Id
        ,WORKERCOMPANYLIST.HOSTDEPARTMENTID AS Current_Host_Department_Id
        ,'{{ invocation_id }}' AS _Audit_Log_Id
        ,SHA2('hash_me') as _Row_Hash -- Adds column to table on full refresh.
	FROM source_data_Workday Workday
	FULL OUTER JOIN source_data_TEACommon TEACommon
	 ON TEACommon.EmployeeId = Workday.EmployeeId
	FULL OUTER JOIN source_data_AD AD
	 ON AD.MailNickname = COALESCE(TEACommon.EmployeeId,Workday.EmployeeId)
    LEFT OUTER JOIN security__company_grouping SecGroup
     ON SecGroup.CompanyId = COALESCE(REPLACE(REPLACE(REGEXP_SubStr(LOWER(COALESCE(TEACommon.Email, AD.UserPrincipalName)),'@\\w+'),'@',''),'tel','asia'),Workday.CompanyCode)
    LEFT OUTER JOIN mdm__employee_type EmployeeType_Workday
     ON EmployeeType_Workday.EmployeeTypeId = Workday.EmployeeType
    LEFT OUTER JOIN mdm__employee_type EmployeeType_TEACommon
     ON EmployeeType_TEACommon.EmployeeTypeId = TO_VARCHAR(TEACommon.EmployeeType)
    LEFT OUTER JOIN mdm__manager_employee_group MDM_SupervisorGrouping
     ON MDM_SupervisorGrouping.SupervisorId = COALESCE(TEACommon.SupervisorID,Workday.SupervisorEmployeeNumber)
    LEFT OUTER JOIN 
        (SELECT * FROM 
            {{ ref('SILVER__TEA_INTEL_SMS__WORKERCOMPANYLIST') }}
            QUALIFY ROW_NUMBER() OVER (PARTITION BY EMPLOYEEID order by HOSTCOMPANYID asc)=1 
        ) WORKERCOMPANYLIST ON COALESCE(TEACommon.EmployeeId, AD.MailNickname,Workday.EmployeeId) = WORKERCOMPANYLIST.EMPLOYEEID
    LEFT OUTER JOIN {{ ref('SILVER__TEA_INTEL_SMS__SHARED_DATASETS_COMPANY') }} HostCompany ON WORKERCOMPANYLIST.HOSTCOMPANYID =  HostCompany.WORKDAY_COMPANY_ID 
        AND  HostCompany.DW_CURRENT_INDICATOR  = 'Y'
    LEFT OUTER JOIN {{ ref('SILVER__TEA_INTEL_SMS__SHARED_DATASETS_COMPANY') }} HomeCompany ON HomeCompany.WORKDAY_COMPANY_ID = WORKERCOMPANYLIST.HOMECOMPANYID 
        AND  HomeCompany.DW_CURRENT_INDICATOR = 'Y'
    LEFT OUTER JOIN supervisor_details SUPERVISOR
        ON SUPERVISOR.EMPLOYEE_ID=COALESCE(TEACommon.SupervisorID,Workday.SupervisorEmployeeNumber)
)
,type_data as
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_Row_Hash as varchar(128)) as _ROW_HASH,
        EMPLOYEE_ID,
        FULL_NAME,
        FIRST_NAME,
        LAST_NAME,
        EMAILADDRESS,
        SUPERVISOR_EMPLOYEE_ID,
        SUPERVISOR_NAME,
        cast(SENIORITY_DATE as DATE) as SENIORITY_DATE,
        cast(HIRE_DATE AS DATE) AS HIRE_DATE,
        cast(REHIRE_DATE as DATE) as REHIRE_DATE,
        cast(TERMINATION_DATE AS DATE) AS TERMINATION_DATE,
        SALARY_TYPE,
        EMPLOYEE_STATUS,
        IS_EXPAT,
        IS_MANAGER,
        BUSINESS_UNIT,
        COMPANY_ID,
        DEPARTMENT_ID,
        OFFICE_ID,
        JOB_TITLE,
        JOB_FAMILY_GROUPNAME,
        EMPLOYEE_TYPE_CODE,
        EMPLOYEE_TYPE,
        EMPLOYEE_TYPE_FST,
        GROUP_NAME_FST,
        ACTIVEDIRECTORYID,
        ACTIVEDIRECTORYDISPLAYNAME,
        IS_IN_WORKDAY,
        IS_IN_TEACOMMON,
        IS_IN_ACTIVEDIRECTORY,
        COMPANY_HR_REGION,
        SECURITY_USERID,
        US_REGION_STATUS,
        IS_MANAGER_FLAG,
        Current_Home_Company_Id,
        Current_Home_Department_Id,
        Current_Host_Company_Id,
        Current_Host_Department_Id
    from transform_data
    )
select * from type_data