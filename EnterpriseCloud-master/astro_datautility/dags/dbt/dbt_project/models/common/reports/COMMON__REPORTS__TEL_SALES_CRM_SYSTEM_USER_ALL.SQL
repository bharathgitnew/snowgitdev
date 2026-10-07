{{ config(
    materialized='incremental',
	incremental_strategy='insert_overwrite',
    alias='TEL_SALES_CRM_SYSTEM_USER_ALL',
    transient=false
) }}

with
Regional
as
(
select 
    ID,
    TITLE,
    FULLNAME,
    LASTNAME,
    EMPLOYEEID,
    '' as BAAN_DESCRIPTION,
    COM_DIVISION_E_NAME,
    case when COM_DIVISION_E_NAME = 'Sales' then 'tsmc'
        when substr(COM_DIVISION_E_NAME, 7) = 'Micron' then 'Micron'
        when substr(COM_DIVISION_E_NAME, 7) = 'Central' then 'TI'
        when substr(COM_DIVISION_E_NAME, 7) in ('West', 'East') then 'Regional'
        when substr(COM_DIVISION_E_NAME, 7) = 'GF' then 'GF/IBM'
        -- when substr(COM_DIVISION_E_NAME, 7) = 'Intel' then 'Intel'
        when substr(COM_DIVISION_E_NAME, 7) = 'SAS' then 'Samsung' else null end as Sales_Account,
    case when COM_DIVISION_E_NAME = 'Sales' then 'tsmc'
        when substr(COM_DIVISION_E_NAME, 7) = 'Micron' then 'Micron'
        when substr(COM_DIVISION_E_NAME, 7) = 'Central' then 'TI'
         when substr(COM_DIVISION_E_NAME, 7) = 'West' then 'Regional West'
        when substr(COM_DIVISION_E_NAME, 7) = 'East' then 'Regional East'
        when substr(COM_DIVISION_E_NAME, 7) = 'GF' then 'GF/IBM'
        -- when substr(COM_DIVISION_E_NAME, 7) = 'Intel' then 'Intel'
        when substr(COM_DIVISION_E_NAME, 7) = 'SAS' then 'Samsung' else null end as Sales_Account_Region,
    COM_COMPANY_NAME,
    ISDISABLED,
    '' as PRODLINECODE,
    '' as SAP_CODE
from {{ ref('COMMON__CRM__SALES_SYSTEMUSER') }}
where COM_COMPANY_NAME = 'TEA'
    and ISDISABLED = 'FALSE'
    and com_division_e_name ilike any ('Sales East', 'Sales West')
    -- and not TITLE ilike any ('%Dir%', '%Mgr%', '%VP%')
),
Strategic
as
(
select 
    crm.ID,
    crm.TITLE,
    crm.FULLNAME,
    crm.LASTNAME,
    crm.EMPLOYEEID,
    bu.BAAN_DESCRIPTION,
    crm.COM_DIVISION_E_NAME,
    case when crm.LASTNAME ilike any ('Lim', 'Cooley', 'McEntee') then 'tsmc'
        when crm.LASTNAME ilike any ('Lee', 'Wolfe', 'Mitzman') then 'Micron'
        when crm.LASTNAME ilike any ('Snyder', 'Burris', 'Koecher', 'Van Every') then 'TI'
        when crm.LASTNAME ilike any ('Prendergust', 'Devlin', 'Hoekstra', 'Puretz') then 'GF/IBM'
        when crm.LASTNAME ilike any ('Guadarrama', 'Pickett') then 'Samsung' else null end as Sales_Account,
    case when crm.LASTNAME ilike any ('Lim', 'Cooley', 'McEntee') then 'tsmc'
        when crm.LASTNAME ilike any ('Lee', 'Wolfe', 'Mitzman') then 'Micron'
        when crm.LASTNAME ilike any ('Snyder', 'Burris', 'Koecher', 'Van Every') then 'TI'
        when crm.LASTNAME ilike any ('Prendergust', 'Devlin', 'Hoekstra', 'Puretz') then 'GF/IBM'
        when crm.LASTNAME ilike any ('Guadarrama', 'Pickett') then 'Samsung' else null end as Sales_Account_Region,
    crm.COM_COMPANY_NAME,
    crm.ISDISABLED,
    emp.PRODLINECODE,
    bu.SAP_CODE
from {{ ref('COMMON__CRM__SALES_SYSTEMUSER') }} crm
left outer join PUB.COMMON_TEACOMMON.EMPLOYEE emp on emp.EMPLOYEEID = crm.EMPLOYEEID
left outer join PUB.DE_SAP_MASTER_DATA.SAP_SEGMENT bu on bu.SAP_CODE = emp.PRODLINECODE and bu.BAAN_DESCRIPTION is not null
where COM_COMPANY_NAME = 'TEA'
    and ISDISABLED = 'FALSE'
    -- and com_division_e_name ='Marketing'
    -- and (crm.TITLE ilike any ('%Sales Representative%', '%Account/Product Sales%', 'Sales Manager')
    --     or crm.FULLNAME = 'Lee David')
    -- and SALES_ACCOUNT is not null
    -- and bu.BAAN_DESCRIPTION <> 'TS'
),
SOURCE_DATA AS (
select *
from Regional

union all
select *
from Strategic
),
TRANSFORM_DATA AS (
SELECT
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
	SHA2('hash_me') AS _ROW_HASH,
	ID,
	TITLE,
	FULLNAME,
	LASTNAME,
	EMPLOYEEID,
	BAAN_DESCRIPTION,
	COM_DIVISION_E_NAME,
	SALES_ACCOUNT,
	SALES_ACCOUNT_REGION,
	COM_COMPANY_NAME,
	ISDISABLED,
	PRODLINECODE,
	SAP_CODE

FROM SOURCE_DATA
)

,
TYPE_DATA AS (
select
	CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
	CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
	ID,
	TITLE,
	FULLNAME,
	LASTNAME,
	EMPLOYEEID,
	BAAN_DESCRIPTION,
	COM_DIVISION_E_NAME,
	SALES_ACCOUNT,
	SALES_ACCOUNT_REGION,
	COM_COMPANY_NAME,
	CAST(ISDISABLED as BOOLEAN) as ISDISABLED,
	PRODLINECODE,
	SAP_CODE
from transform_data
)
SELECT * FROM TYPE_DATA