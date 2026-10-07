{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SALES_CRM_ACCOUNT',
    transient=false
) }}

WITH
SOURCE_DATA AS (

select 
    account.ID                                  as Account_ID,
	account.NAME                                as Account_Name,
	account.ACCOUNTNUMBER                       as Account_Code,
    left(TEL_COM_OLD_CUSTOMER_CODE,5)           as _5_Digit_Old_Customer_Code,
	region.Sales_Region,
    case when Account_Code = 'BA9223406' then 'N/A' --Regional Customers US
        when Account_Code = 'BA3883601' then 'tsmc'
        when Account_Code is null and account.NAME ilike 'OTHERS' then 'N/A'
        when Account_Name ilike 'tsmc%' then 'tsmc'
        when Account_Name ilike any ('TI-%', 'TI/%', 'TI', 'TI %', 'TEXAS INSTRUMENTS%', 'NXP%') then 'TI/NXP'
        when Account_Name ilike any ('MICRON%', 'MESA MOVING%') and not account.NAME ilike any ('MICRONITY%', 'MICRONAS') then 'Micron'
        when Account_Name ilike any ('INTEL%', '%Intel%') then 'Intel'
        when Account_Name ilike any ('SAMSUNG%', 'SAS%') then 'Samsung'
        when Account_Name ilike any ('GF%', 'GLOBALFOUN%', 'IBM%', 'RF SUNY%', 'SU OF NY', 'SUNY%', 'YORKTOWN', 'ALBANY NANO%', 'THE RESEARCH FOUNDATION%') then 'GF/IBM' 
        when Account_Name like any ('TEA%', 'TMEA%', 'TEL Group%', 'TTCA%') then 'TEL Group'
        else 'Regional' 
    end                     as Sales_Account,
    case when Account_Code = 'BA9223406' then 'N/A' --Regional Customers US
        when Account_Code = 'BA3883601' then 'tsmc'
        when Account_Code is null and account.NAME ilike 'OTHERS' then 'N/A'
        when Account_Name ilike 'tsmc%' then 'tsmc'
        when Account_Name ilike any ('TI-%', 'TI/%', 'TI', 'TI %', 'TEXAS INSTRUMENTS%') then 'TI'
        when Account_Name ilike 'NXP%' then 'Regional'
        when Account_Name ilike any ('MICRON%', 'MESA MOVING%') and not account.NAME ilike any ('MICRONITY%', 'MICRONAS') then 'Micron'
        when Account_Name ilike any ('INTEL%', '%Intel%') then 'Intel'
        when Account_Name ilike any ('SAMSUNG%', 'SAS%') then 'Samsung'
        when Account_Name ilike any ('GF%', 'GLOBALFOUN%') then 'GF'
        when Account_Name ilike any ('IBM%', 'RF SUNY%', 'SU OF NY', 'SUNY%', 'YORKTOWN', 'ALBANY NANO%', 'THE RESEARCH FOUNDATION%', 'HFC%') then 'IBM'
        when Account_Name ilike any ('TEA%', 'TMEA%', 'TEL Group%', 'TTCA%') then 'TEL Group'
        else 'Regional'
    end                     as _Sales_Account,
    case when Account_Code = 'BA9223406' then 'N/A' --Regional Customers US
        when Account_Code = 'BA3883601' then 'tsmc'
        when Account_Code is null and account.NAME ilike 'OTHERS' then 'N/A'
        when Account_Name ilike 'tsmc%' then 'tsmc'
        when Account_Name ilike any ('TI-%', 'TI/%', 'TI', 'TI %', 'TEXAS INSTRUMENTS%') then 'TI'
        when Account_Name ilike 'NXP%' then 'Regional'
        when Account_Name ilike any ('MICRON%', 'MESA MOVING%') and not account.NAME ilike any ('MICRONITY%', 'MICRONAS') then 'Micron'
        when Account_Name ilike any ('INTEL%', '%Intel%') then 'Intel'
        when Account_Name ilike any ('SAMSUNG%', 'SAS%') then 'Samsung'
        when Account_Name ilike any ('GF%', 'GLOBALFOUN%', 'IBM%', 'RF SUNY%', 'SU OF NY', 'SUNY%', 'YORKTOWN', 'ALBANY NANO%', 'THE RESEARCH FOUNDATION%', 'HFC%') then 'GF/IBM'
        when Account_Name ilike any ('TEA%', 'TMEA%', 'TEL Group%', 'TTCA%') then 'TEL Group'
        else 'Regional' 
    end                     as Sales_Account_TI,
    case when Sales_Account_TI = 'Regional' then CONCAT(Sales_Account_TI, ' ', Sales_Region)
        else Sales_Account_TI 
    end                     as Sales_Account_Region,
    case when _Sales_Account = 'Regional' then CONCAT(_Sales_Account, ' ', Sales_Region)
        else _Sales_Account 
    end                     as _Sales_Account_Region
from {{ ref('SILVER__TEH_SALES_TO_INSTALLATION__ACCOUNT') }} account
    left outer join {{ ref('SILVER__TEH_SALES_TO_INSTALLATION__SALES_CRM_SALES_REGION') }} region on region.ACCOUNT_NUMBER = account.ACCOUNTNUMBER
where STARTSWITH(Account_Code, 'A')
    or STARTSWITH(Account_Code, 'B')
    or STARTSWITH(Account_Code, 'C')
    or STARTSWITH(Account_Code, 'D')
    or Account_Code in ('Z1', 'Z2', 'Z3', 'Z4', 'Z5', 'Z01', 'Z02', 'Z03', 'Z04', 'Z05', 'Z06', 'Z10') 
    or Account_Code like any ('E%', 'U%')
),
TRANSFORM_DATA AS (
SELECT
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
	SHA2('hash_me') AS _ROW_HASH,
	ACCOUNT_ID,
	ACCOUNT_NAME,
	ACCOUNT_CODE,
	_5_DIGIT_OLD_CUSTOMER_CODE,
	SALES_REGION,
	SALES_ACCOUNT,
	_SALES_ACCOUNT,
	SALES_ACCOUNT_TI,
	SALES_ACCOUNT_REGION,
	_SALES_ACCOUNT_REGION

FROM SOURCE_DATA

)

,
TYPE_DATA AS (
SELECT
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	ACCOUNT_ID,
	ACCOUNT_NAME,
	ACCOUNT_CODE,
	_5_DIGIT_OLD_CUSTOMER_CODE,
	SALES_REGION,
	SALES_ACCOUNT,
	_SALES_ACCOUNT,
	SALES_ACCOUNT_TI,
	SALES_ACCOUNT_REGION,
	_SALES_ACCOUNT_REGION
FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA