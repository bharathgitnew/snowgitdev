{{ config(
        alias = 'COMMON_US_CUSTOMER_B_CODE',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as (
SELECT 
        Account_ID,
        Account_Name,
	Account_Code,
	_5_Digit_Old_Customer_Code,
	SALES_REGION,
        SALES_ACCOUNT,
        _SALES_ACCOUNT
from {{ ref('BRONZE__TEH_EQUIPMENT_SALES__SHAREPOINT_COMMON_SALES_ACCOUNT') }}
-- FROM COPPER.TEH_EQUIPMENT_SALES.COMMON_SALES_ACCOUNT_TEMP  --replace with BRONZE.TEH_EQUIPMENT_SALES.COMMON_SALES_ACCOUNT
WHERE STARTSWITH(Account_Code, 'B')
and COUNTRY ilike any ('USA', 'Canada', 'Mexico')
),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        Account_ID,
	Account_Name,
	Account_Code,
	_5_Digit_Old_Customer_Code,
	SALES_REGION,
        SALES_ACCOUNT,
        _SALES_ACCOUNT
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        Account_ID,
	Account_Name,
	Account_Code,
	_5_Digit_Old_Customer_Code,
	SALES_REGION,
        SALES_ACCOUNT,
        _SALES_ACCOUNT
from transform_data
)

select * from type_data