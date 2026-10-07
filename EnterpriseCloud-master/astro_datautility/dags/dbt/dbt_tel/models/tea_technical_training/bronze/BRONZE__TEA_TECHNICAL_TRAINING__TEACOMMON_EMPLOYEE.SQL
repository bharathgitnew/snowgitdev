/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-TEACommon\Employee.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\teacommon\EMPLOYEE.SQL
-materialized incremental
-alias EMPLOYEE
-incremental_strategy merge
-envVariable <<LZ>>
-sourceSchema TEACOMMON
-sourceDatabase LZ_DEV
-useDistinct no
model file generated on: 1/13/2022 1:04:00 AM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='TEACOMMON_EMPLOYEE',
    unique_key = ['EmployeeID']
) }}


with source_data as
(
    SELECT distinct
           Employee._Filename as _Filename
          ,Employee._Filedate as _Filedate
          ,JSonField:CompanyID::STRING AS CompanyID
          ,JSonField:EmployeeID::STRING AS EmployeeID
          ,JSonField:ADPCompany::STRING AS ADPCompany
          ,JSonField:ADPPersonID::STRING AS ADPPersonID
          ,JSonField:Active::STRING AS Active
          ,JSonField:EmployeeType::INTEGER AS EmployeeType
          ,JSonField:FirstName::STRING AS FirstName
          ,JSonField:LastName::STRING AS LastName
          ,JSonField:NameUsed::STRING AS NameUsed
          ,JSonField:ADPPosnID::STRING AS ADPPosnID
          ,JSonField:JobCode::STRING AS JobCode
          ,JSonField:JobTitle::STRING AS JobTitle
          ,JSonField:Email::STRING AS Email
          ,JSonField:SupervisorID::STRING AS SupervisorID
          ,JSonField:DeptCode::STRING AS DeptCode
          ,JSonField:ProdLineCode::STRING AS ProdLineCode
          ,JSonField:LocationCode::STRING AS LocationCode
          ,JSonField:State::STRING AS State
          ,JSonField:MailStop::STRING AS MailStop
          ,JSonField:OffcPhone::STRING AS OffcPhone
          ,JSonField:OffcExt::STRING AS OffcExt
          ,JSonField:OffcPagerModel::STRING AS OffcPagerModel
          ,JSonField:OffcPager::STRING AS OffcPager
          ,JSonField:OffcPin::STRING AS OffcPin
          ,JSonField:OffcPageCovArea::STRING AS OffcPageCovArea
          ,JSonField:OffcDispatch::STRING AS OffcDispatch
          ,JSonField:OffcFax::STRING AS OffcFax
          ,JSonField:OffcPagerEmail::STRING AS OffcPagerEmail
          ,JSonField:CustLocalPager::STRING AS CustLocalPager
          ,JSonField:CustLocalPin::STRING AS CustLocalPin
          ,JSonField:MobilePhone::STRING AS MobilePhone
          ,JSonField:Seniority_Date::STRING AS SeniorityDate
          ,JSonField:FTE::STRING AS FTE
          ,JSonField:DateHire::STRING AS HireDate
          ,JSonField:DateTerm::STRING AS TermDate
          ,JSonField:SalaryExempt::STRING AS SalaryExempt
          ,JSonField:PreferredLanguage::STRING AS PreferredLanguage
          ,JSonField:FleetAuto::STRING AS FleetAuto
          ,JSonField:Kronos_AccrualCode::STRING AS Kronos_AccrualCode
          ,JSonField:Kronos_PayRule::STRING AS Kronos_PayRule
          ,JSonField:Kronos_WorkRule::STRING AS Kronos_WorkRule
          ,JSonField:Kronos_AccessCode::STRING AS Kronos_AccessCode
          ,JSonField:Kronos_LaborLevel::STRING AS Kronos_LaborLevel
          ,JSonField:Kronos_PayCodeDataAccess::STRING AS Kronos_PayCodeDataAccess
          ,JSonField:Kronos_DisplayProfile::STRING AS Kronos_DisplayProfile
          ,JSonField:NTDomain::STRING AS NTDomain
          ,JSonField:NTLogin::STRING AS NTLogin
          ,JSonField:Project::STRING AS Project
          ,JSonField:LastUpdated::STRING AS LastUpdated
          ,JSonField:LastUpdatedBy::STRING AS LastUpdatedBy
          ,JSonField:MiddleInitial::STRING AS MiddleInitial
          ,JSonField:Suffix::STRING AS Suffix
          ,JSonField:RehireDate::STRING AS RehireDate
          ,JSonField:isManager::STRING AS isManager
          ,JSonField:Status_Code::STRING AS StatusCode
          ,JSonField:HRRep::STRING AS HRRep
          ,JSonField:WorkGroup::STRING AS WorkGroup
          ,JSonField:BUMgr::STRING AS BUMgr
          ,JSonField:EEType::STRING AS EEType
          ,JSonField:WFH::STRING AS WFH
          ,JSonField:inactive::STRING AS inactive
          ,JSonField:VendorName::STRING AS VendorName
          ,JSonField:Job_Family::STRING AS Job_Family
          ,JSonField:SupervisoryOrg::STRING AS SupervisoryOrg
          ,JSonField:Function1::STRING AS Function1
          ,JSonField:CostCenter::STRING AS CostCenter
          ,JSonField:CoCode::STRING AS CoCode
          ,JSonField:StdHier::STRING AS StdHier
          ,JSonField:OldDeptCode::STRING AS OldDeptCode
          ,JSonField:OldProdLineCode::STRING AS OldProdLineCode
        FROM {{ source("TEACOMMON", "EMPLOYEE") }}  AS Employee
        WHERE Employee._Filedate = (SELECT MAX(_FileDate) FROM {{ source("TEACOMMON", "EMPLOYEE") }})
        AND  1=1 
        QUALIFY ROW_NUMBER() OVER (PARTITION BY EmployeeId ORDER BY CASE WHEN JSonField:Active::BOOLEAN THEN 0 ELSE 1 END, LastUpdated DESC, COALESCE(TermDate,'/Date(9999999999999)/') DESC) = 1
        )
,transform_data as
(
    SELECT
        source_data.COMPANYID AS CompanyID,
        source_data.EMPLOYEEID AS EmployeeID,
        source_data.ADPCOMPANY AS ADPCompany,
        source_data.ADPPERSONID AS ADP_Person_ID,
        source_data.ACTIVE AS Active,
        source_data.EMPLOYEETYPE AS EmployeeType,
        source_data.FIRSTNAME AS FirstName,
        source_data.LASTNAME AS LastName,
        source_data.NAMEUSED AS NameUsed,
        source_data.ADPPOSNID AS ADP_Posn_ID,
        source_data.JOBCODE AS JobCode,
        source_data.JOBTITLE AS JobTitle,
        source_data.EMAIL AS Email,
        source_data.SUPERVISORID AS SupervisorID,
        source_data.DEPTCODE AS DeptCode,
        source_data.PRODLINECODE AS ProdLineCode,
        source_data.LOCATIONCODE AS LocationCode,
        source_data.STATE AS State,
        source_data.MAILSTOP AS MailStop,
        source_data.OFFCPHONE AS OffcPhone,
        source_data.OFFCEXT AS OffcExt,
        source_data.OFFCPAGERMODEL AS OffcPagerModel,
        source_data.OFFCPAGER AS OffcPager,
        source_data.OFFCPIN AS OffcPin,
        source_data.OFFCPAGECOVAREA AS OffcPageCovArea,
        source_data.OFFCDISPATCH AS OffcDispatch,
        source_data.OFFCFAX AS OffcFax,
        source_data.OFFCPAGEREMAIL AS OffcPagerEmail,
        source_data.CUSTLOCALPAGER AS CustLocalPager,
        source_data.CUSTLOCALPIN AS CustLocalPin,
        source_data.MOBILEPHONE AS MobilePhone,
        TO_DATE ( TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.SENIORITYDATE , '/Date(' , '' ) , ')/' , '' ) ) ) AS Seniority_Date,
        source_data.FTE AS FTE,
        TO_DATE ( TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.HIREDATE , '/Date(' , '' ) , ')/' , '' ) ) ) AS DateHire,
        TO_DATE ( TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.TERMDATE , '/Date(' , '' ) , ')/' , '' ) ) ) AS DateTerm,
        source_data.SALARYEXEMPT AS SalaryExempt,
        source_data.PREFERREDLANGUAGE AS PreferredLanguage,
        source_data.FLEETAUTO AS FleetAuto,
        source_data.KRONOS_ACCRUALCODE AS Kronos_Accrual_Code,
        source_data.KRONOS_PAYRULE AS Kronos_Pay_Rule,
        source_data.KRONOS_WORKRULE AS Kronos_Work_Rule,
        source_data.KRONOS_ACCESSCODE AS Kronos_Access_Code,
        source_data.KRONOS_LABORLEVEL AS Kronos_Labor_Level,
        source_data.KRONOS_PAYCODEDATAACCESS AS Kronos_Pay_Code_Data_Access,
        source_data.KRONOS_DISPLAYPROFILE AS Kronos_Display_Profile,
        source_data.NTDOMAIN AS NTDomain,
        source_data.NTLOGIN AS NTLogin,
        source_data.PROJECT AS Project,
        TO_DATE ( TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.LASTUPDATED , '/Date(' , '' ) , ')/' , '' ) ) ) AS LastUpdated,
        source_data.LASTUPDATEDBY AS LastUpdatedBy,
        source_data.MIDDLEINITIAL AS Middle_Initial,
        source_data.SUFFIX AS Suffix,
        TO_DATE ( TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.REHIREDATE , '/Date(' , '' ) , ')/' , '' ) ) ) AS RehireDate,
        source_data.ISMANAGER AS isManager,
        source_data.STATUSCODE AS Status_Code,
        source_data.HRREP AS HRRep,
        source_data.WORKGROUP AS WorkGroup,
        source_data.BUMGR AS BUMgr,
        source_data.EETYPE AS EEType,
        source_data.WFH AS WFH,
        source_data.INACTIVE AS inactive,
        source_data.VENDORNAME AS VendorName,
        source_data.JOB_FAMILY AS Job_Family,
        source_data.SUPERVISORYORG AS Supervisory_Org,
        source_data.FUNCTION1 AS Function1,
        source_data.COSTCENTER AS CostCenter,
        source_data.COCODE AS CoCode,
        source_data.STDHIER AS StdHier,
        source_data.OLDDEPTCODE AS OldDeptCode,
        source_data.OLDPRODLINECODE AS OldProdLineCode,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(COMPANYID as VARCHAR(16777216)) as COMPANYID,
        cast(EMPLOYEEID as VARCHAR(16777216)) as EMPLOYEEID,
        cast(ADPCOMPANY as VARCHAR(16777216)) as ADPCOMPANY,
        cast(ADP_PERSON_ID as VARCHAR(16777216)) as ADP_PERSON_ID,
        cast(ACTIVE as VARCHAR(16777216)) as ACTIVE,
        cast(EMPLOYEETYPE as NUMBER(38,0)) as EMPLOYEETYPE,
        cast(FIRSTNAME as VARCHAR(16777216)) as FIRSTNAME,
        cast(LASTNAME as VARCHAR(16777216)) as LASTNAME,
        cast(NAMEUSED as VARCHAR(16777216)) as NAMEUSED,
        cast(ADP_POSN_ID as VARCHAR(16777216)) as ADP_POSN_ID,
        cast(JOBCODE as VARCHAR(16777216)) as JOBCODE,
        cast(JOBTITLE as VARCHAR(16777216)) as JOBTITLE,
        cast(EMAIL as VARCHAR(16777216)) as EMAIL,
        cast(SUPERVISORID as VARCHAR(16777216)) as SUPERVISORID,
        cast(DEPTCODE as VARCHAR(16777216)) as DEPTCODE,
        cast(PRODLINECODE as VARCHAR(16777216)) as PRODLINECODE,
        cast(LOCATIONCODE as VARCHAR(16777216)) as LOCATIONCODE,
        cast(STATE as VARCHAR(16777216)) as STATE,
        cast(MAILSTOP as VARCHAR(16777216)) as MAILSTOP,
        cast(OFFCPHONE as VARCHAR(16777216)) as OFFCPHONE,
        cast(OFFCEXT as VARCHAR(16777216)) as OFFCEXT,
        cast(OFFCPAGERMODEL as VARCHAR(16777216)) as OFFCPAGERMODEL,
        cast(OFFCPAGER as VARCHAR(16777216)) as OFFCPAGER,
        cast(OFFCPIN as VARCHAR(16777216)) as OFFCPIN,
        cast(OFFCPAGECOVAREA as VARCHAR(16777216)) as OFFCPAGECOVAREA,
        cast(OFFCDISPATCH as VARCHAR(16777216)) as OFFCDISPATCH,
        cast(OFFCFAX as VARCHAR(16777216)) as OFFCFAX,
        cast(OFFCPAGEREMAIL as VARCHAR(16777216)) as OFFCPAGEREMAIL,
        cast(CUSTLOCALPAGER as VARCHAR(16777216)) as CUSTLOCALPAGER,
        cast(CUSTLOCALPIN as VARCHAR(16777216)) as CUSTLOCALPIN,
        cast(MOBILEPHONE as VARCHAR(16777216)) as MOBILEPHONE,
        cast(SENIORITY_DATE as DATE) as SENIORITY_DATE,
        cast(FTE as VARCHAR(16777216)) as FTE,
        cast(DATEHIRE as DATE) as DATEHIRE,
        cast(DATETERM as DATE) as DATETERM,
        cast(SALARYEXEMPT as VARCHAR(16777216)) as SALARYEXEMPT,
        cast(PREFERREDLANGUAGE as VARCHAR(16777216)) as PREFERREDLANGUAGE,
        cast(FLEETAUTO as VARCHAR(16777216)) as FLEETAUTO,
        cast(KRONOS_ACCRUAL_CODE as VARCHAR(16777216)) as KRONOS_ACCRUAL_CODE,
        cast(KRONOS_PAY_RULE as VARCHAR(16777216)) as KRONOS_PAY_RULE,
        cast(KRONOS_WORK_RULE as VARCHAR(16777216)) as KRONOS_WORK_RULE,
        cast(KRONOS_ACCESS_CODE as VARCHAR(16777216)) as KRONOS_ACCESS_CODE,
        cast(KRONOS_LABOR_LEVEL as VARCHAR(16777216)) as KRONOS_LABOR_LEVEL,
        cast(KRONOS_PAY_CODE_DATA_ACCESS as VARCHAR(16777216)) as KRONOS_PAY_CODE_DATA_ACCESS,
        cast(KRONOS_DISPLAY_PROFILE as VARCHAR(16777216)) as KRONOS_DISPLAY_PROFILE,
        cast(NTDOMAIN as VARCHAR(16777216)) as NTDOMAIN,
        cast(NTLOGIN as VARCHAR(16777216)) as NTLOGIN,
        cast(PROJECT as VARCHAR(16777216)) as PROJECT,
        cast(LASTUPDATED as VARCHAR(16777216)) as LASTUPDATED,
        cast(LASTUPDATEDBY as VARCHAR(16777216)) as LASTUPDATEDBY,
        cast(MIDDLE_INITIAL as VARCHAR(16777216)) as MIDDLE_INITIAL,
        cast(SUFFIX as VARCHAR(16777216)) as SUFFIX,
        cast(REHIREDATE as DATE) as REHIREDATE,
        cast(ISMANAGER as VARCHAR(16777216)) as ISMANAGER,
        cast(STATUS_CODE as VARCHAR(16777216)) as STATUS_CODE,
        cast(HRREP as VARCHAR(16777216)) as HRREP,
        cast(WORKGROUP as VARCHAR(16777216)) as WORKGROUP,
        cast(BUMGR as VARCHAR(16777216)) as BUMGR,
        cast(EETYPE as VARCHAR(16777216)) as EETYPE,
        cast(WFH as VARCHAR(16777216)) as WFH,
        cast(INACTIVE as VARCHAR(16777216)) as INACTIVE,
        cast(VENDORNAME as VARCHAR(16777216)) as VENDORNAME,
        cast(JOB_FAMILY as VARCHAR(16777216)) as JOB_FAMILY,
        cast(SUPERVISORY_ORG as VARCHAR(16777216)) as SUPERVISORY_ORG,
        cast(FUNCTION1 as VARCHAR(16777216)) as FUNCTION1,
        cast(COSTCENTER as VARCHAR(16777216)) as COSTCENTER,
        cast(COCODE as VARCHAR(16777216)) as COCODE,
        cast(STDHIER as VARCHAR(16777216)) as STDHIER,
        cast(OLDDEPTCODE as VARCHAR(16777216)) as OLDDEPTCODE,
        cast(OLDPRODLINECODE as VARCHAR(16777216)) as OLDPRODLINECODE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data