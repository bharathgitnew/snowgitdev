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
        source_data._Filename,
        source_data._Filedate,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        _Filedate as _FILEDATE,
        _Filename AS _FILENAME,
        _AUDIT_LOG_ID as _AUDIT_LOG_ID,
        _ROW_HASH as _ROW_HASH,
        COMPANYID as COMPANYID,
        EMPLOYEEID as EMPLOYEEID,
        ADPCOMPANY as ADPCOMPANY,
        ADP_PERSON_ID as ADP_PERSON_ID,
        ACTIVE as ACTIVE,
        cast(EMPLOYEETYPE as NUMBER(38,0)) as EMPLOYEETYPE,
        FIRSTNAME as FIRSTNAME,
        LASTNAME as LASTNAME,
        NAMEUSED as NAMEUSED,
        ADP_POSN_ID as ADP_POSN_ID,
        JOBCODE as JOBCODE,
        JOBTITLE as JOBTITLE,
        EMAIL as EMAIL,
        SUPERVISORID as SUPERVISORID,
        DEPTCODE as DEPTCODE,
        PRODLINECODE as PRODLINECODE,
        LOCATIONCODE as LOCATIONCODE,
        STATE as STATE,
        MAILSTOP as MAILSTOP,
        OFFCPHONE as OFFCPHONE,
        OFFCEXT as OFFCEXT,
        OFFCPAGERMODEL as OFFCPAGERMODEL,
        OFFCPAGER as OFFCPAGER,
        OFFCPIN as OFFCPIN,
        OFFCPAGECOVAREA as OFFCPAGECOVAREA,
        OFFCDISPATCH as OFFCDISPATCH,
        OFFCFAX as OFFCFAX,
        OFFCPAGEREMAIL as OFFCPAGEREMAIL,
        CUSTLOCALPAGER as CUSTLOCALPAGER,
        CUSTLOCALPIN as CUSTLOCALPIN,
        MOBILEPHONE as MOBILEPHONE,
        cast(SENIORITY_DATE as DATE) as SENIORITY_DATE,
        FTE as FTE,
        cast(DATEHIRE as DATE) as DATEHIRE,
        cast(DATETERM as DATE) as DATETERM,
        SALARYEXEMPT as SALARYEXEMPT,
        PREFERREDLANGUAGE as PREFERREDLANGUAGE,
        FLEETAUTO as FLEETAUTO,
        KRONOS_ACCRUAL_CODE as KRONOS_ACCRUAL_CODE,
        KRONOS_PAY_RULE as KRONOS_PAY_RULE,
        KRONOS_WORK_RULE as KRONOS_WORK_RULE,
        KRONOS_ACCESS_CODE as KRONOS_ACCESS_CODE,
        KRONOS_LABOR_LEVEL as KRONOS_LABOR_LEVEL,
        KRONOS_PAY_CODE_DATA_ACCESS as KRONOS_PAY_CODE_DATA_ACCESS,
        KRONOS_DISPLAY_PROFILE as KRONOS_DISPLAY_PROFILE,
        NTDOMAIN as NTDOMAIN,
        NTLOGIN as NTLOGIN,
        PROJECT as PROJECT,
        LASTUPDATED as LASTUPDATED,
        LASTUPDATEDBY as LASTUPDATEDBY,
        MIDDLE_INITIAL as MIDDLE_INITIAL,
        SUFFIX as SUFFIX,
        cast(REHIREDATE as DATE) as REHIREDATE,
        ISMANAGER as ISMANAGER,
        STATUS_CODE as STATUS_CODE,
        HRREP as HRREP,
        WORKGROUP as WORKGROUP,
        BUMGR as BUMGR,
        EETYPE as EETYPE,
        WFH as WFH,
        INACTIVE as INACTIVE,
        VENDORNAME as VENDORNAME,
        JOB_FAMILY as JOB_FAMILY,
        SUPERVISORY_ORG as SUPERVISORY_ORG,
        FUNCTION1 as FUNCTION1,
        COSTCENTER as COSTCENTER,
        COCODE as COCODE,
        STDHIER as STDHIER,
        OLDDEPTCODE as OLDDEPTCODE,
        OLDPRODLINECODE as OLDPRODLINECODE
    from transform_data
    )
select * from type_data