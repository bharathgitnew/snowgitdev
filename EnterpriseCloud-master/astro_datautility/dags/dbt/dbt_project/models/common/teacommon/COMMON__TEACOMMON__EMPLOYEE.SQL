{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='Employee',
    unique_key = ['EmployeeId']
) }}


with source_data as
(
    SELECT
		COMPANYID,
		EMPLOYEEID,
		ADPCOMPANY,
		ADP_PERSON_ID,
		ACTIVE,
		EMPLOYEETYPE,
		FIRSTNAME,
		LASTNAME,
		NAMEUSED,
		ADP_POSN_ID,
		JOBCODE,
		JOBTITLE,
		EMAIL,
		SUPERVISORID,
		DEPTCODE,
		PRODLINECODE,
		LOCATIONCODE,
		STATE,
		MAILSTOP,
		OFFCPHONE,
		OFFCEXT,
		OFFCPAGERMODEL,
		OFFCPAGER,
		OFFCPIN,
		OFFCPAGECOVAREA,
		OFFCDISPATCH,
		OFFCFAX,
		OFFCPAGEREMAIL,
		CUSTLOCALPAGER,
		CUSTLOCALPIN,
		MOBILEPHONE,
		SENIORITY_DATE,
		FTE,
		DATEHIRE,
		DATETERM,
		SALARYEXEMPT,
		PREFERREDLANGUAGE,
		FLEETAUTO,
		KRONOS_ACCRUAL_CODE,
		KRONOS_PAY_RULE,
		KRONOS_WORK_RULE,
		KRONOS_ACCESS_CODE,
		KRONOS_LABOR_LEVEL,
		KRONOS_PAY_CODE_DATA_ACCESS,
		KRONOS_DISPLAY_PROFILE,
		NTDOMAIN,
		NTLOGIN,
		PROJECT,
		LASTUPDATED,
		LASTUPDATEDBY,
		MIDDLE_INITIAL,
		SUFFIX,
		REHIREDATE,
		ISMANAGER,
		STATUS_CODE as SOURCE_STATUS_CODE,
		HRREP,
		WORKGROUP,
		BUMGR,
		EETYPE,
		WFH,
		INACTIVE,
		VENDORNAME,
		JOB_FAMILY,
		SUPERVISORY_ORG,
		FUNCTION1,
        COSTCENTER,
        COCODE,
        STDHIER,
        OLDDEPTCODE,
        OLDPRODLINECODE
	FROM {{ ref('ODS__TEACOMMON__EMPLOYEE') }}
)
,FST_EMPLOYEE_GROUP
AS (
	SELECT FSTSupervisorID,
		FSTSupervisorName,
		FSTEmployeeGroup AS FST,
		RegionalServiceManagerID,
		RSMFlag,
		RegionalServiceManager
	FROM {{ ref('ODS__FILE__FST_EMPLOYEE_GROUP') }}
),
BUMAP
AS (
	SELECT BU_GROUP,
	BU_GROUP_LEADER,
	BU_SOURCE_KEY
	FROM {{ ref('ODS__SHAREPOINT__SERVICE_BUSINESS_UNIT_MAPPING') }}
),
ORACLE_DEPARTMENT as (
	select distinct SAP_CODE, SAP_NAME from {{ ref('ODS__SHAREPOINT__ORACLE_DEPARTMENT') }}
),
transform_data
AS (
	SELECT
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
        source_data.COMPANYID,
		source_data.EMPLOYEEID,
		source_data.ADPCOMPANY,
		source_data.ADP_PERSON_ID,
		source_data.ACTIVE,
		source_data.EMPLOYEETYPE,
		source_data.FIRSTNAME,
		source_data.LASTNAME,
		source_data.NAMEUSED,
		source_data.ADP_POSN_ID,
		source_data.JOBCODE,
		source_data.JOBTITLE,
		source_data.EMAIL,
		source_data.SUPERVISORID,
		source_data.DEPTCODE,
		source_data.PRODLINECODE,
		source_data.LOCATIONCODE,
		source_data.STATE,
		source_data.MAILSTOP,
		source_data.OFFCPHONE,
		source_data.OFFCEXT,
		source_data.OFFCPAGERMODEL,
		source_data.OFFCPAGER,
		source_data.OFFCPIN,
		source_data.OFFCPAGECOVAREA,
		source_data.OFFCDISPATCH,
		source_data.OFFCFAX,
		source_data.OFFCPAGEREMAIL,
		source_data.CUSTLOCALPAGER,
		source_data.CUSTLOCALPIN,
		source_data.MOBILEPHONE,
		source_data.SENIORITY_DATE,
		source_data.FTE,
		source_data.DATEHIRE,
		source_data.DATETERM,
		source_data.SALARYEXEMPT,
		source_data.PREFERREDLANGUAGE,
		source_data.FLEETAUTO,
		source_data.KRONOS_ACCRUAL_CODE,
		source_data.KRONOS_PAY_RULE,
		source_data.KRONOS_WORK_RULE,
		source_data.KRONOS_ACCESS_CODE,
		source_data.KRONOS_LABOR_LEVEL,
		source_data.KRONOS_PAY_CODE_DATA_ACCESS,
		source_data.KRONOS_DISPLAY_PROFILE,
		source_data.NTDOMAIN,
		source_data.NTLOGIN,
		source_data.PROJECT,
		try_to_date(source_data.LASTUPDATED) as LASTUPDATED,
		source_data.LASTUPDATEDBY,
		source_data.MIDDLE_INITIAL,
		source_data.SUFFIX,
		source_data.REHIREDATE,
		source_data.ISMANAGER,
        CASE WHEN source_data.SOURCE_STATUS_CODE = 'A' and source_data.Active = 'false' THEN 'T'
        ELSE source_data.SOURCE_STATUS_CODE END AS STATUS_CODE,
		source_data.HRREP,
		source_data.WORKGROUP,
		source_data.BUMGR,
		source_data.EETYPE,
		source_data.WFH,
		source_data.INACTIVE,
		source_data.VENDORNAME,
		source_data.JOB_FAMILY,
		source_data.SUPERVISORY_ORG,
		source_data.FUNCTION1,
        source_data.COSTCENTER,
        source_data.COCODE,
        source_data.STDHIER,
        case when source_data.OLDDEPTCODE is null then source_data.deptcode else source_data.OLDDEPTCODE END as OLDDEPTCODE,
        case when source_data.OLDPRODLINECODE is null then source_data.prodlinecode else source_data.OLDPRODLINECODE END as OLDPRODLINECODE,
		CASE
			WHEN source_data.PRODLINECODE IN ('5999','33') THEN 'FST'
			WHEN source_data.DEPTCODE IN ('7600', '7601', '053', '054') Then 'Tech Support'
			ELSE 'Other'
		END AS FSTEMPLOYEEGROUP,
		CASE
			WHEN source_data.PRODLINECODE IN ('5999','33') THEN 'Yes'
			ELSE 'No'
		END AS ISFSTEMPLOYEE,
		case
			when source_data.COMPANYID = 'TEA'
				and STATUS_CODE in ('A','L')
				and len(source_data.NAMEUSED) > 1
			then source_data.LASTNAME || ', ' || source_data.NAMEUSED
			else source_data.LASTNAME || ', ' || source_data.FIRSTNAME
		end as FULLNAME,
		CASE source_data.EmployeeType WHEN 1 THEN 'Regular Full-Time'
			WHEN 2 THEN 'Subcontractor'
			WHEN 3 THEN 'Temp Worker'
			ELSE 'Unknown'
			END AS EMPLOYEE_TYPE_NAME,
		case
			when SUPERVISOR.COMPANYID = 'TEA'
				and (SUPERVISOR.SOURCE_STATUS_CODE = 'L' or (SUPERVISOR.SOURCE_STATUS_CODE = 'A' and SUPERVISOR.Active != 'false'))
				and len(SUPERVISOR.NAMEUSED) > 1
			then SUPERVISOR.LASTNAME || ', ' || SUPERVISOR.NAMEUSED
			else SUPERVISOR.LASTNAME || ', ' || SUPERVISOR.FIRSTNAME
		end as SUPERVISOR_NAME,
		CASE WHEN (source_data.Active = 'false' and  upper(source_data.CompanyID) != 'TEA') THEN coalesce(dept.description,dept_old.description)
		when upper(source_data.CompanyID) = 'TEA' then DEP.SAP_NAME
        ELSE dept.description END AS DEPARTMENT_NAME,
        CASE WHEN source_data.Active = 'false' THEN coalesce(bu.description,bu_old.description)
        ELSE bu.description END AS BUSINESS_UNIT_NAME,
		loc.description AS OFFICE_NAME,
		CASE
			WHEN source_data.ADPCompany IN ('FIU','FMW','HXQ','T24','C3K','FHS','Monthly')THEN 'Expat'
			ELSE NULL
			END AS EXPAT_FLAG,
		BUMAP.BU_GROUP,
		BUMAP.BU_GROUP_LEADER,
		source_data.LASTNAME || ', ' || source_data.FIRSTNAME AS LEGALFULLNAME,
	FROM source_data
	LEFT OUTER JOIN source_data Supervisor ON Supervisor.EmployeeID = source_data.SupervisorID
	LEFT OUTER JOIN FST_EMPLOYEE_GROUP FSTSUP ON source_data.SUPERVISORID = FSTSUP.FSTSupervisorID
	LEFT OUTER JOIN FST_EMPLOYEE_GROUP RSM ON source_data.EMPLOYEEID = RSM.RegionalServiceManagerID
		AND RSM.RSMFlag = 'Y'
    LEFT JOIN {{ ref('ODS__TEACOMMON__DEPARTMENTS') }} dept ON source_data.CompanyId = dept.CompanyID
	AND ltrim(rtrim(source_data.DeptCode)) = ltrim(rtrim(dept.DeptCode))
    LEFT JOIN {{ ref('ODS__TEACOMMON__DEPARTMENTS') }} dept_old ON source_data.CompanyId = dept_old.CompanyID
	AND ltrim(rtrim(source_data.OLDDEPTCODE)) = ltrim(rtrim(dept_old.DeptCode))
    LEFT JOIN {{ ref('ODS__TEACOMMON__PRODUCTLINES') }} bu ON source_data.CompanyId = bu.CompanyID
	AND ltrim(rtrim(source_data.ProdLineCode)) = ltrim(rtrim(bu.ProdLineCode))
    LEFT JOIN {{ ref('ODS__TEACOMMON__PRODUCTLINES') }} bu_old ON source_data.CompanyId = bu_old.CompanyID
	 AND ltrim(rtrim(source_data.OldProdLineCode)) = ltrim(rtrim(bu_old.ProdLineCode))
    LEFT JOIN {{ ref('ODS__TEACOMMON__LOCATIONS') }} loc ON source_data.CompanyId = loc.CompanyID
	AND source_data.LocationCode = loc.LocationCode
	LEFT JOIN BUMAP ON BUMAP.BU_SOURCE_KEY=source_data.COSTCENTER
	left join ORACLE_DEPARTMENT AS DEP
	on source_data.DEPTCODE = DEP.SAP_CODE
)
,type_data as
(
	SELECT
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		COMPANYID,
		EMPLOYEEID,
		ADPCOMPANY,
		ADP_PERSON_ID,
		ACTIVE,
		CAST(EMPLOYEETYPE AS NUMBER(38,0)) AS EMPLOYEETYPE,
		FIRSTNAME,
		LASTNAME,
		NAMEUSED,
		ADP_POSN_ID,
		JOBCODE,
		JOBTITLE,
		EMAIL,
		SUPERVISORID,
		DEPTCODE,
		PRODLINECODE,
		LOCATIONCODE,
		STATE,
		MAILSTOP,
		OFFCPHONE,
		OFFCEXT,
		OFFCPAGERMODEL,
		OFFCPAGER,
		OFFCPIN,
		OFFCPAGECOVAREA,
		OFFCDISPATCH,
		OFFCFAX,
		OFFCPAGEREMAIL,
		CUSTLOCALPAGER,
		CUSTLOCALPIN,
		MOBILEPHONE,
		CAST(SENIORITY_DATE AS DATE) AS SENIORITY_DATE,
		FTE,
		CAST(DATEHIRE AS DATE) AS DATEHIRE,
		CAST(DATETERM AS DATE) AS DATETERM,
		SALARYEXEMPT,
		PREFERREDLANGUAGE,
		FLEETAUTO,
		KRONOS_ACCRUAL_CODE,
		KRONOS_PAY_RULE,
		KRONOS_WORK_RULE,
		KRONOS_ACCESS_CODE,
		KRONOS_LABOR_LEVEL,
		KRONOS_PAY_CODE_DATA_ACCESS,
		KRONOS_DISPLAY_PROFILE,
		NTDOMAIN,
		NTLOGIN,
		PROJECT,
		CAST(LASTUPDATED AS DATE) AS LASTUPDATED,
		LASTUPDATEDBY,
		MIDDLE_INITIAL,
		SUFFIX,
		CAST(REHIREDATE AS DATE) AS REHIREDATE,
		ISMANAGER,
		STATUS_CODE,
		HRREP,
		WORKGROUP,
		BUMGR,
		EETYPE,
		WFH,
		INACTIVE,
		VENDORNAME,
		JOB_FAMILY,
		SUPERVISORY_ORG,
		FUNCTION1,
		COSTCENTER,
		COCODE,
		STDHIER,
		OLDDEPTCODE,
		OLDPRODLINECODE,
		FULLNAME,
		ISFSTEMPLOYEE,
		FSTEMPLOYEEGROUP,
		EMPLOYEE_TYPE_NAME,
		SUPERVISOR_NAME,
		DEPARTMENT_NAME,
		BUSINESS_UNIT_NAME,
		OFFICE_NAME,
		EXPAT_FLAG,
		BU_GROUP,
		BU_GROUP_LEADER,
		LEGALFULLNAME,
	from transform_data
)

Select * from type_data