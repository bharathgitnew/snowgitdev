{{ config(
    materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
    alias='TEL_SALES_CRM_CALL_REPORT',
    transient=false
) }}

WITH
SOURCE_DATA AS (

select
    report.ID                                                   as CALL_REPORT_ID,
    report.SM_NAME                                              as CALL_REPORT_NAME,
    case when report.SM_CALL_REPORT_TYPE = '100000001' then 'Win Report'
        when report.SM_CALL_REPORT_TYPE = '100000002' then 'Lost Report'
        else null
    end                                                         as REPORT_TYPE,
	case when report.TEL_SM_STATUS = '100000001' then 'Green'
        when report.TEL_SM_STATUS = '100000002' then 'Yellow'
        when report.TEL_SM_STATUS = '100000003' then 'Red'
        else null
    end                                                         as BUSINESS_STATUS,
	case when report.TEL_SM_IMPORTANCE ilike 'TRUE' then 'High'
        else null
    end                                                         as BUSINESS_IMPORTANCE,
    to_date(report.SM_VISIT_DATE)                               as VISIT_DATE,
	to_date(report.CREATEDON)                                   as CREATED_DATE,
    model.TEL_SM_MODEL                                          as MODEL,
	report.SM_ACCOUNT_GROUPNAME                                 as ACCOUNT_GROUP,
    case when report.SM_ACCOUNT_GROUPNAME ilike 'Samsung' then 'Samsung' 
        when report.SM_ACCOUNT_GROUPNAME ilike 'intel' then 'Intel' 
        when report.SM_ACCOUNT_GROUPNAME ilike 'Micron' then 'Micron' 
        when report.SM_ACCOUNT_GROUPNAME ilike 'tsmc' then 'tsmc' 
        when startswith(report.SM_ACCOUNTNAME, 'TI') then 'TI' 
        when startswith(report.SM_ACCOUNTNAME, 'GF ') then 'GF/IBM'  
        when startswith(report.SM_ACCOUNTNAME, 'IBM') then 'GF/IBM' 
        else 'Regional'
    end                                                         as SALES_ACCOUNT,
	report.SM_ACCOUNTNAME                                       as CUSTOMER_NAME,
    report.SM_FAB_LINENAME                                      as FAB,
	report.TEL_SM_DEVICE_TYPENAME                               as DEVICE_TYPE,
	report.SM_PROCESS                                           as PROCESS,
    report.TEL_SM_NODENAME                                      as NODE,
	report.SM_QUANTITY                                          as QUANTITY,
	report.SM_UNIT                                              as UNIT,
	report.SM_CALL_REPORT_CONTENT                               as REPORT_CONTENT,
    report.SM_TEL_PROPOSAL_NOTE                                 as PROPOSAL_NOTE,
    case when report.CREATEDBYNAME ilike 'SalesCall Report%' then createdbyoriginal.EMPLOYEEID
        else createdby.EMPLOYEEID
    end                                                         as EMPLOYEE_ID,
    -- case when report.CREATEDBYNAME ilike 'SalesCall Report%' then createdbyoriginal.DOMAINNAME
    --     else createdby.DOMAINNAME
    -- end                                                         as EMPLOYEE_EMAIL,
    case when report.CREATEDBYNAME ilike 'SalesCall Report%' then report.SM_CREATEDBY_ORIGINALNAME
        else report.CREATEDBYNAME
    end                                                         as CREATED_BY,
    emp.LASTNAME                                                as LAST_NAME,
    emp.JOBTITLE                                                as JOB_TITLE,
    emp.BUSINESS_UNIT_NAME,
    emp.EXPAT_FLAG,
    report.TEL_SM_ACCOUNT_CD                                    as CUSTOMER_CODE,
    report.TEL_SM_FAB_LINE_CD                                   as FAB_CODE
from {{ ref('SILVER__TEH_EQUIPMENT_SALES__SALES_SM_CALL_REPORT') }} report
left outer join {{ ref('SILVER__TEH_EQUIPMENT_SALES__SALES_SYSTEMUSER') }} createdby on createdby.ID = report.CREATEDBY
left outer join {{ ref('SILVER__TEH_EQUIPMENT_SALES__SALES_SYSTEMUSER') }} createdbyoriginal on createdbyoriginal.ID = report.SM_CREATEDBY_ORIGINAL
left outer join {{ ref('GOLD__TEH_EQUIPMENT_SALES__EMPLOYEE') }} emp on emp.EMPLOYEEID = case when report.CREATEDBYNAME ilike 'SalesCall Report%' then createdbyoriginal.EMPLOYEEID
        else createdby.EMPLOYEEID end 
left outer join {{ ref('SILVER__TEH_EQUIPMENT_SALES__MODEL') }} model on model.MODEL_ID = report.TEL_SM_MODEL
where report.STATECODE <> 2
    and report.STATUSCODE <> 2
    and report.CREATEDBYNAME <> 'ENCRMSERVICE%'
    and report.SM_DRAFT ilike 'FALSE'
    and emp.COMPANYID ilike 'TEA'
    and not emp.ACTIVE ilike 'FALSE'
    and to_date(report.CREATEDON) >= coalesce(emp.REHIREDATE, emp.DATEHIRE) 
    and to_date(report.CREATEDON) <= case when emp.DATETERM is not null then emp.DATETERM else current_date() end
),
TRANSFORM_DATA AS (
SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        CALL_REPORT_ID,
        CALL_REPORT_NAME,
        REPORT_TYPE,
        BUSINESS_STATUS,
        BUSINESS_IMPORTANCE,
        VISIT_DATE,
        CREATED_DATE,
        MODEL,
        ACCOUNT_GROUP,
        SALES_ACCOUNT,
        CUSTOMER_NAME,
        FAB,
        DEVICE_TYPE,
        PROCESS,
        NODE,
        QUANTITY,
        UNIT,
        REPORT_CONTENT,
        PROPOSAL_NOTE,
        EMPLOYEE_ID,
        CREATED_BY,
        LAST_NAME,
        JOB_TITLE,
        BUSINESS_UNIT_NAME,
        EXPAT_FLAG,
        CUSTOMER_CODE,
        FAB_CODE
FROM SOURCE_DATA

)

,
TYPE_DATA AS (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CALL_REPORT_ID,
        CALL_REPORT_NAME,
        REPORT_TYPE,
        BUSINESS_STATUS,
        BUSINESS_IMPORTANCE,
        CAST(VISIT_DATE as DATE) as VISIT_DATE,
        CAST(CREATED_DATE as DATE) as CREATED_DATE,
        MODEL,
        ACCOUNT_GROUP,
        SALES_ACCOUNT,
        CUSTOMER_NAME,
        FAB,
        DEVICE_TYPE,
        PROCESS,
        NODE,
        QUANTITY,
        UNIT,
        REPORT_CONTENT,
        PROPOSAL_NOTE,
        EMPLOYEE_ID,
        CREATED_BY,
        LAST_NAME,
        JOB_TITLE,
        BUSINESS_UNIT_NAME,
        EXPAT_FLAG,
        CUSTOMER_CODE,
        FAB_CODE
from transform_data
)
SELECT * FROM TYPE_DATA