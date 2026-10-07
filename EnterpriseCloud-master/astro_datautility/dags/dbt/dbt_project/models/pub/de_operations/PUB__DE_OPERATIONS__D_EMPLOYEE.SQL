{{ config(
      materialized='view',
      alias='D_EMPLOYEE',
      transient=false
) }}


with source_data as (
    select
    DISTINCT
        SHA2('hash_me') AS EMPLOYEE_KEY,
        EMPLOYEE_ID AS EMPLOYEE_ID,
        FULL_NAME AS FULL_NAME,
        FIRST_NAME AS FIRST_NAME,
        LAST_NAME AS LAST_NAME,
        JOB_TITLE AS JOB_TITLE,
        EMPLOYEE_STATUS AS EMPLOYEE_STATUS,
        EMAILADDRESS AS EMAIL_ADDRESS,
        SUPERVISOR_NAME AS SUPERVISOR_NAME,
        BUSINESS_UNIT AS BUSINESS_UNIT_Id,
        HIRE_DATE AS HIRE_DATE,
        REHIRE_DATE AS REHIRE_DATE,
        TERMINATION_DATE AS TERMINATION_DATE,
        US_REGION_STATUS AS US_REGION_STATUS,
        SENIORITY_DATE AS SENIORITY_DATE,
        EMPLOYEE_TYPE AS EMPLOYEE_TYPE,
        Employee_Type_FST AS EMPLOYEETYPEFST,
        EMPLOYEE_TYPE_CODE AS EMPLOYEE_TYPE_CODE,
        SALARY_TYPE AS SALARY_TYPE,
        IS_EXPAT AS IS_EXPAT,
        IS_MANAGER AS IS_MANAGER,
        Job_Family_GroupName AS JOB_FAMILY_GROUP_NAME,
        Company_HR_Region AS Company_HR_Region,
        Security_UserId AS Security_UserId,
        ActiveDirectoryId AS ActiveDirectory_Id,
        ActiveDirectoryDisplayName AS ActiveDirectory_Display_Name,
        Supervisor_Employee_Id AS Supervisor_Employee_Id,
        Current_Home_Company_Id AS Current_Home_Company_Id,
        Current_Home_Department_Id AS Current_Home_Department_Id,
        Current_Host_Company_Id AS Current_Host_Company_Id,
        Current_Host_Department_Id AS Current_Host_Department_Id,
        GROUP_NAME_FST AS GroupNameFST,
        Office_Id AS Office_Id,
        IS_IN_ACTIVEDIRECTORY AS Is_InActiveDirectory,
        IS_IN_WORKDAY AS Is_InWorkday,
        IS_IN_TEACOMMON AS Is_InTEACommon,
        'Y' AS DW_CURRENT_INDICATOR,
        to_timestamp_ntz ('1900-01-01') AS DW_EFFECTIVE_DATETIME,
        '9999-12-31' AS DW_EXPIRATION_DATETIME,
        NULL AS DW_HASHVALUE_SCDTYPE1,
        NULL AS DW_HASHVALUE_SCDTYPE2,
        Current_Timestamp(2) AS DW_INSERT_DATETIME,
        Current_Timestamp(2) AS DW_UPDATE_DATETIME,
        NULL AS OFFICE_PHONE,
        '0' AS ERROR_FLAG,
        '' AS ERROR_REASON,
        '' AS ERROR_CODE,
        LOCALTIMESTAMP AS RECORD_INSERT_TIMESTAMP,
        'INSERT' AS OPERATION_TYPE
    FROM {{ ref('COMMON__SHARED_DATASETS__GLOBAL_EMPLOYEE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data