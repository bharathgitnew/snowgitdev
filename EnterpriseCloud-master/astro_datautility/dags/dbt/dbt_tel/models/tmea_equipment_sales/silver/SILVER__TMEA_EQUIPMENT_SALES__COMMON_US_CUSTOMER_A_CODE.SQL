{{ config(
        alias = 'COMMON_US_CUSTOMER_A_CODE',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as (
SELECT account_id,
       account_name,
       account_code,
       _5_digit_old_customer_code,
       sales_region,
       sales_account,
       _sales_account
from {{ ref('BRONZE__TMEA_EQUIPMENT_SALES__SHAREPOINT_COMMON_SALES_ACCOUNT') }}
-- FROM   copper.teh_equipment_sales.common_sales_account_temp --replace with BRONZE.TEH_EQUIPMENT_SALES.COMMON_SALES_ACCOUNT
WHERE  Startswith(account_code, 'A')
AND    country ilike ANY ('USA', 'Canada', 'Mexico')
),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        ACCOUNT_ID,
	ACCOUNT_NAME,
	ACCOUNT_CODE,
	_5_DIGIT_OLD_CUSTOMER_CODE,
	SALES_REGION,
	SALES_ACCOUNT,
	_SALES_ACCOUNT
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        ACCOUNT_ID,
	ACCOUNT_NAME,
	ACCOUNT_CODE,
	_5_DIGIT_OLD_CUSTOMER_CODE,
	SALES_REGION,
	SALES_ACCOUNT,
	_SALES_ACCOUNT
from transform_data
)

select * from type_data