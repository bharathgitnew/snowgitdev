{{ config(
        alias = 'EMPLOYEE',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    SELECT 
		 EMPLOYEE_ID
		,FULL_NAME
		,FIRST_NAME
		,LAST_NAME
		,EMPLOYEE_STATUS
		,EMAIL_ADDRESS
		,SUPERVISOR_NAME
		,Office_Phone
		,Employee_Type_Code
		,EmployeeTypeFST
		,Salary_Type
		,IS_Expat
		,Is_Manager
        ,Business_Unit_ID
        ,Supervisor_Employee_ID
        ,Current_Home_Company_ID
        ,Current_Home_Department_ID
        ,Current_Host_Company_ID
        ,Current_Host_Department_ID
        ,GroupNameFST
FROM  {{ source('EDW__DE', 'D_EMPLOYEE') }} 
WHERE DW_Current_Indicator = 'Y'
)

,transform_data as 
(
    SELECT
    EMPLOYEE_ID,
	FULL_NAME,
	FIRST_NAME,
	LAST_NAME,
	EMPLOYEE_STATUS,
	EMAIL_ADDRESS,
	SUPERVISOR_NAME,
	OFFICE_PHONE,
	EMPLOYEE_TYPE_CODE,
	EMPLOYEETYPEFST as EMPLOYEE_TYPE_FST,
	SALARY_TYPE,
	IS_EXPAT,
	IS_MANAGER,
	BUSINESS_UNIT_ID,
	SUPERVISOR_EMPLOYEE_ID,
	CURRENT_HOME_COMPANY_ID,
	CURRENT_HOME_DEPARTMENT_ID,
	CURRENT_HOST_COMPANY_ID,
	CURRENT_HOST_DEPARTMENT_ID,
	GROUPNAMEFST as GROUP_NAME_FST
    from source_data
)

select * from transform_data