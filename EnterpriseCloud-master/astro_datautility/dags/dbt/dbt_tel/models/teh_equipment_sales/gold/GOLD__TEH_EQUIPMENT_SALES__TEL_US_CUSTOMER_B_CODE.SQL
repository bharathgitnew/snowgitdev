{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TEL_US_CUSTOMER_B_CODE',
    transient=false
) }}

WITH
SOURCE_DATA AS (

SELECT 
    Account_ID,
	Account_Name,
	Account_Code,
	_5_Digit_Old_Customer_Code,
	SALES_REGION,
    SALES_ACCOUNT,
	SALES_ACCOUNT_TI,
    _SALES_ACCOUNT
FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT') }}
WHERE STARTSWITH(Account_Code, 'B')
    AND Sales_Region IS NOT NULL
    -- OR Account_Code IN ('Z1', 'Z2', 'Z3', 'Z4', 'Z5', 'Z01', 'Z02', 'Z03', 'Z04', 'Z05', 'Z06', 'Z10') 
    -- OR Account_Code LIKE ANY ('E%', 'U%')
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
        SALES_ACCOUNT_TI,
        _SALES_ACCOUNT
FROM SOURCE_DATA

)

,
TYPE_DATA AS (
SELECT
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        ACCOUNT_ID,
        ACCOUNT_NAME,
        ACCOUNT_CODE,
        _5_DIGIT_OLD_CUSTOMER_CODE,
        SALES_REGION,
        SALES_ACCOUNT,
        SALES_ACCOUNT_TI,
        CAST(_SALES_ACCOUNT as VARCHAR(9)) as _SALES_ACCOUNT
FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA