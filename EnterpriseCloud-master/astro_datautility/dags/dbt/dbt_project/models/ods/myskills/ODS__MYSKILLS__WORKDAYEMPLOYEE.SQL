/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Repository\EnterpriseCloud\Snowflake\LZ_2_ODS-MySkills\WorkdayEmployee__MySkills_WorkdayEmployee.SQL
-newFile C:\Repository\EnterpriseCloud\dbt\lz_to_ods\models\myskills\WorkdayEmployee.SQL
-materialized incremental
-alias WorkdayEmployee
-incremental_strategy merge
-envVariable <<LZ>>
-sourceSchema MYSKILLS
-sourceDatabase LZ_DEV
-useDistinct no
model file generated on: 1/12/2022 6:09:19 AM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='WorkdayEmployee',
    unique_key = ['EMPLOYEEID']
) }}

with server_data as
(
    SELECT
         _Filename as _Filename
         ,_Filedate as _Filedate
         ,JSonField:EmployeeId::STRING AS EmployeeId
         ,JSonField:EmployeeName::STRING AS EmployeeName
         ,JSonField:LastFirstName::STRING AS LastFirstName
         ,JSonField:FirstLastName::STRING AS FirstLastName
         ,JSonField:LastNameKana::STRING AS LastNameKana
         ,JSonField:FirstNameKana::STRING AS FirstNameKana
         ,JSonField:LastNameJa::STRING AS LastNameJa
         ,JSonField:FirstNameJa::STRING AS FirstNameJa
         ,JSonField:LastNameEn::STRING AS LastNameEn
         ,JSonField:FirstNameEn::STRING AS FirstNameEn
         ,JSonField:CompanyCode::STRING AS CompanyCode
         ,JSonField:DepartmentGroupCode::STRING AS DepartmentGroupCode
         ,JSonField:WorkLocationCode::STRING AS WorkLocationCode
         ,JSonField:EmployeeStatusCode::STRING AS EmployeeStatusCode
         ,JSonField:UserJobPostNameJa::STRING AS UserJobPostNameJa
         ,JSonField:UserJobPostNameEn::STRING AS UserJobPostNameEn
         ,JSonField:AnnouncedOnString::STRING AS AnnouncedOnString
         ,JSonField:UserJobExpiredOnString::STRING AS UserJobExpiredOnString
         ,JSonField:EmployeeTypeCode::STRING AS EmployeeTypeCode
         ,JSonField:UserJobPostCode::STRING AS UserJobPostCode
         ,JSonField:UserJobPrimary::STRING AS UserJobPrimary
         ,JSonField:AdditionalJobCode::STRING AS AdditionalJobCode
         ,JSonField:JobFamilyGroupCode::STRING AS JobFamilyGroupCode
         ,JSonField:JobFamilyGroupNameJa::STRING AS JobFamilyGroupNameJa
         ,JSonField:JobFamilyGroupNameEn::STRING AS JobFamilyGroupNameEn
         ,JSonField:JobFamilyCode::STRING AS JobFamilyCode
         ,JSonField:JobFamilyNameJa::STRING AS JobFamilyNameJa
         ,JSonField:JobFamilyNameEn::STRING AS JobFamilyNameEn
         ,JSonField:ManagementLevel::STRING AS ManagementLevel
         ,JSonField:CareerBand::STRING AS CareerBand
         ,JSonField:BPInitiatorEmployeeNumber::STRING AS BPInitiatorEmployeeNumber
         ,JSonField:BPApproverEmployeeNumber::STRING AS BPApproverEmployeeNumber
         ,JSonField:BPApprovedOnString::STRING AS BPApprovedOnString
         ,JSonField:TrainerEmployeeNumber::STRING AS TrainerEmployeeNumber
         ,JSonField:LocalTerminationReason::STRING AS LocalTerminationReason
         ,JSonField:JobClassificationFullID::STRING AS JobClassificationFullID
         ,JSonField:GTCTitle::STRING AS GTCTitle
         ,JSonField:TEAProductLine::STRING AS TEAProductLine
         ,JSonField:EmployeeType::STRING AS EmployeeType
         ,JSonField:OriginalHireDate::STRING AS OriginalHireDate
         ,JSonField:SeniorityDate::STRING AS SeniorityDate
         ,JSonField:AssignmentStartDate::STRING AS AssignmentStartDate
         ,JSonField:SupervisoryOrganization::STRING AS SupervisoryOrganization
         ,JSonField:BusinessTitle::STRING AS BusinessTitle
         ,JSonField:Region::STRING AS Region
         ,JSonField:Expatinfo::STRING AS Expatinfo
         ,JSonField:SupervisorEmployeeNumber::STRING AS SupervisorEmployeenumber
    {%- if is_incremental() %}
        FROM {{ source("MYSKILLS", "WORKDAYEMPLOYEE") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("MYSKILLS", "WORKDAYEMPLOYEE") }})
    {%- else %}
        FROM {{ source("MYSKILLS", "WORKDAYEMPLOYEE") }}
        QUALIFY (ROW_NUMBER() OVER ( PARTITION BY EMPLOYEEID ORDER BY _Filedate DESC )) = 1
    {%- endif %}
        ),
WorkDayEmployeeOrdering AS(
  SELECT 
    EmployeeId, 
    LastNameKana, 
    FirstNameKana, 
    LastNameJa, 
    FirstNameJa, 
    LastNameEn, 
    FirstNameEn, 
    EmployeeName, 
    LastFirstName, 
    FirstLastName, 
    CompanyCode, 
    DepartmentGroupCode, 
    WorkLocationCode, 
    EmployeeStatusCode, 
    UserJobPostNameJa, 
    UserJobPostNameEn, 
    AnnouncedOnString, 
    UserJobExpiredOnString, 
    EmployeeTypeCode, 
    UserJobPostCode, 
    UserJobPrimary, 
    AdditionalJobCode, 
    JobFamilyGroupCode, 
    JobFamilyGroupNameJa, 
    JobFamilyGroupNameEn, 
    JobFamilyCode, 
    JobFamilyNameJa, 
    JobFamilyNameEn, 
    ManagementLevel, 
    CareerBand, 
    BPInitiatorEmployeeNumber, 
    BPApproverEmployeeNumber, 
    BPApprovedOnString, 
    TrainerEmployeeNumber, 
    LocalTerminationReason, 
    JobClassificationFullID, 
    GTCTitle, 
    TEAProductLine, 
    EmployeeType, 
    OriginalHireDate, 
    SeniorityDate, 
    AssignmentStartDate, 
    SupervisoryOrganization, 
    BusinessTitle, 
    Region, 
    Expatinfo, 
    SupervisorEmployeeNumber, 
    ROW_NUMBER() OVER (
      PARTITION BY EmployeeId 
      ORDER BY 
        IFNULL(UserJobPrimary, 3) ASC, 
        AnnouncedOnString DESC
    ) RowId 
  FROM 
    server_data
  WHERE 
    AnnouncedOnString <= REGEXP_REPLACE(to_varchar(current_date()),'-')
), 

source_data AS (
  SELECT 
    EmployeeId, 
    LastNameKana, 
    FirstNameKana, 
    LastNameJa, 
    FirstNameJa, 
    LastNameEn, 
    FirstNameEn, 
    EmployeeName, 
    LastFirstName, 
    FirstLastName, 
    CompanyCode, 
    DepartmentGroupCode, 
    WorkLocationCode, 
    EmployeeStatusCode, 
    UserJobPostNameJa, 
    UserJobPostNameEn, 
    AnnouncedOnString, 
    UserJobExpiredOnString, 
    EmployeeTypeCode, 
    UserJobPostCode, 
    UserJobPrimary, 
    AdditionalJobCode, 
    JobFamilyGroupCode, 
    JobFamilyGroupNameJa, 
    JobFamilyGroupNameEn, 
    JobFamilyCode, 
    JobFamilyNameJa, 
    JobFamilyNameEn, 
    ManagementLevel, 
    CareerBand, 
    BPInitiatorEmployeeNumber, 
    BPApproverEmployeeNumber, 
    BPApprovedOnString, 
    TrainerEmployeeNumber, 
    LocalTerminationReason, 
    JobClassificationFullID, 
    GTCTitle, 
    TEAProductLine, 
    EmployeeType, 
    OriginalHireDate, 
    SeniorityDate, 
    AssignmentStartDate, 
    SupervisoryOrganization, 
    BusinessTitle, 
    Region, 
    Expatinfo, 
    SupervisorEmployeeNumber 
  FROM 
    WorkDayEmployeeOrdering 
  WHERE 
    RowID = 1
)
,transform_data as
(
    SELECT
        source_data.EMPLOYEEID AS EMPLOYEEID,
        source_data.LASTNAMEKANA AS LASTNAMEKANA,
        source_data.FIRSTNAMEKANA AS FIRSTNAMEKANA,
        source_data.LASTNAMEJA AS LASTNAMEJA,
        source_data.FIRSTNAMEJA AS FIRSTNAMEJA,
        source_data.LASTNAMEEN AS LASTNAMEEN,
        source_data.FIRSTNAMEEN AS FIRSTNAMEEN,
        source_data.COMPANYCODE AS COMPANYCODE,
        source_data.DEPARTMENTGROUPCODE AS DEPARTMENTGROUPCODE,
        source_data.WORKLOCATIONCODE AS WORKLOCATIONCODE,
        source_data.EMPLOYEESTATUSCODE AS EMPLOYEESTATUSCODE,
        source_data.USERJOBPOSTNAMEJA AS USERJOBPOSTNAMEJA,
        source_data.USERJOBPOSTNAMEEN AS USERJOBPOSTNAMEEN,
        TO_DATE ( source_data.ANNOUNCEDONSTRING , 'YYYYMMDD' ) AS ANNOUNCEDONSTRING,
        source_data.USERJOBEXPIREDONSTRING AS USERJOBEXPIREDONSTRING,
        source_data.EMPLOYEETYPECODE AS EMPLOYEETYPECODE,
        source_data.USERJOBPOSTCODE AS USERJOBPOSTCODE,
        source_data.USERJOBPRIMARY AS USERJOBPRIMARY,
        source_data.ADDITIONALJOBCODE AS ADDITIONALJOBCODE,
        source_data.JOBFAMILYGROUPCODE AS JOBFAMILYGROUPCODE,
        source_data.JOBFAMILYGROUPNAMEJA AS JOBFAMILYGROUPNAMEJA,
        source_data.JOBFAMILYGROUPNAMEEN AS JOBFAMILYGROUPNAMEEN,
        source_data.JOBFAMILYCODE AS JOBFAMILYCODE,
        source_data.JOBFAMILYNAMEJA AS JOBFAMILYNAMEJA,
        source_data.JOBFAMILYNAMEEN AS JOBFAMILYNAMEEN,
        source_data.MANAGEMENTLEVEL AS MANAGEMENTLEVEL,
        source_data.CAREERBAND AS CAREERBAND,
        source_data.BPINITIATOREMPLOYEENUMBER AS BPINITIATOREMPLOYEENUMBER,
        source_data.BPAPPROVEREMPLOYEENUMBER AS BPAPPROVEREMPLOYEENUMBER,
        source_data.BPAPPROVEDONSTRING AS BPAPPROVEDONSTRING,
        source_data.TRAINEREMPLOYEENUMBER AS TRAINEREMPLOYEENUMBER,
        source_data.LOCALTERMINATIONREASON AS LOCALTERMINATIONREASON,
        source_data.JOBCLASSIFICATIONFULLID AS JOBCLASSIFICATIONFULLID,
        source_data.GTCTITLE AS GTCTITLE,
        source_data.TEAPRODUCTLINE AS TEAPRODUCTLINE,
        source_data.EMPLOYEETYPE AS EMPLOYEETYPE,
        TO_DATE ( source_data.ORIGINALHIREDATE , 'YYYYMMDD' ) AS ORIGINALHIREDATE,
        TO_DATE ( source_data.SENIORITYDATE , 'YYYYMMDD' ) AS SENIORITYDATE,
        TO_DATE ( source_data.ASSIGNMENTSTARTDATE , 'YYYYMMDD' ) AS ASSIGNMENTSTARTDATE,
        source_data.SUPERVISORYORGANIZATION AS SUPERVISORYORGANIZATION,
        source_data.BUSINESSTITLE AS BUSINESSTITLE,
        source_data.REGION AS REGION,
        source_data.EXPATINFO AS EXPATINFO,
        source_data.SUPERVISOREMPLOYEENUMBER AS SUPERVISOREMPLOYEENUMBER,
        source_data.EMPLOYEENAME AS EMPLOYEENAME,
        source_data.LASTFIRSTNAME AS LASTFIRSTNAME,
        source_data.FIRSTLASTNAME AS FIRSTLASTNAME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(EMPLOYEEID as VARCHAR(16777216)) as EMPLOYEEID,
        cast(LASTNAMEKANA as VARCHAR(16777216)) as LASTNAMEKANA,
        cast(FIRSTNAMEKANA as VARCHAR(16777216)) as FIRSTNAMEKANA,
        cast(LASTNAMEJA as VARCHAR(16777216)) as LASTNAMEJA,
        cast(FIRSTNAMEJA as VARCHAR(16777216)) as FIRSTNAMEJA,
        cast(LASTNAMEEN as VARCHAR(16777216)) as LASTNAMEEN,
        cast(FIRSTNAMEEN as VARCHAR(16777216)) as FIRSTNAMEEN,
        cast(COMPANYCODE as VARCHAR(16777216)) as COMPANYCODE,
        cast(DEPARTMENTGROUPCODE as VARCHAR(16777216)) as DEPARTMENTGROUPCODE,
        cast(WORKLOCATIONCODE as VARCHAR(16777216)) as WORKLOCATIONCODE,
        cast(EMPLOYEESTATUSCODE as VARCHAR(16777216)) as EMPLOYEESTATUSCODE,
        cast(USERJOBPOSTNAMEJA as VARCHAR(16777216)) as USERJOBPOSTNAMEJA,
        cast(USERJOBPOSTNAMEEN as VARCHAR(16777216)) as USERJOBPOSTNAMEEN,
        cast(ANNOUNCEDONSTRING as DATE) as ANNOUNCEDONSTRING,
        cast(USERJOBEXPIREDONSTRING as VARCHAR(16777216)) as USERJOBEXPIREDONSTRING,
        cast(EMPLOYEETYPECODE as VARCHAR(16777216)) as EMPLOYEETYPECODE,
        cast(USERJOBPOSTCODE as VARCHAR(16777216)) as USERJOBPOSTCODE,
        cast(USERJOBPRIMARY as VARCHAR(16777216)) as USERJOBPRIMARY,
        cast(ADDITIONALJOBCODE as VARCHAR(16777216)) as ADDITIONALJOBCODE,
        cast(JOBFAMILYGROUPCODE as VARCHAR(16777216)) as JOBFAMILYGROUPCODE,
        cast(JOBFAMILYGROUPNAMEJA as VARCHAR(16777216)) as JOBFAMILYGROUPNAMEJA,
        cast(JOBFAMILYGROUPNAMEEN as VARCHAR(16777216)) as JOBFAMILYGROUPNAMEEN,
        cast(JOBFAMILYCODE as VARCHAR(16777216)) as JOBFAMILYCODE,
        cast(JOBFAMILYNAMEJA as VARCHAR(16777216)) as JOBFAMILYNAMEJA,
        cast(JOBFAMILYNAMEEN as VARCHAR(16777216)) as JOBFAMILYNAMEEN,
        cast(MANAGEMENTLEVEL as VARCHAR(16777216)) as MANAGEMENTLEVEL,
        cast(CAREERBAND as VARCHAR(16777216)) as CAREERBAND,
        cast(BPINITIATOREMPLOYEENUMBER as VARCHAR(16777216)) as BPINITIATOREMPLOYEENUMBER,
        cast(BPAPPROVEREMPLOYEENUMBER as VARCHAR(16777216)) as BPAPPROVEREMPLOYEENUMBER,
        cast(BPAPPROVEDONSTRING as VARCHAR(16777216)) as BPAPPROVEDONSTRING,
        cast(TRAINEREMPLOYEENUMBER as VARCHAR(16777216)) as TRAINEREMPLOYEENUMBER,
        cast(LOCALTERMINATIONREASON as VARCHAR(16777216)) as LOCALTERMINATIONREASON,
        cast(JOBCLASSIFICATIONFULLID as VARCHAR(16777216)) as JOBCLASSIFICATIONFULLID,
        cast(GTCTITLE as VARCHAR(16777216)) as GTCTITLE,
        cast(TEAPRODUCTLINE as VARCHAR(16777216)) as TEAPRODUCTLINE,
        cast(EMPLOYEETYPE as VARCHAR(16777216)) as EMPLOYEETYPE,
        cast(ORIGINALHIREDATE as DATE) as ORIGINALHIREDATE,
        cast(SENIORITYDATE as DATE) as SENIORITYDATE,
        cast(ASSIGNMENTSTARTDATE as DATE) as ASSIGNMENTSTARTDATE,
        cast(SUPERVISORYORGANIZATION as VARCHAR(16777216)) as SUPERVISORYORGANIZATION,
        cast(BUSINESSTITLE as VARCHAR(16777216)) as BUSINESSTITLE,
        cast(REGION as VARCHAR(16777216)) as REGION,
        cast(EXPATINFO as VARCHAR(16777216)) as EXPATINFO,
        cast(SUPERVISOREMPLOYEENUMBER as VARCHAR(16777216)) as SUPERVISOREMPLOYEENUMBER,
        cast(EMPLOYEENAME as VARCHAR(16777216)) as EMPLOYEENAME,
        cast(LASTFIRSTNAME as VARCHAR(16777216)) as LASTFIRSTNAME,
        cast(FIRSTLASTNAME as VARCHAR(16777216)) as FIRSTLASTNAME,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data