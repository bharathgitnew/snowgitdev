{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SAP_SALES_ACCOUNT_REGION',
    transient=false
) }}

WITH
SOURCE_DATA AS (

select
case when CORPORATION_NAME ilike 'THE RESEARCH FOUNDATION%' then 'IBM'
    when CORPORATION_NAME ilike 'IBM%' then 'IBM'
    when CUSTOMER_GROUP = 'GF' then 'GF'
    when CUSTOMER_GROUP = 'TSMC' then 'tsmc'
    when CORPORATION_NAME ilike 'wafer%' then 'tsmc'
    when CUSTOMER_GROUP is not null then CUSTOMER_GROUP
    else 'Regional' 
end                         as Sales_Account,
CORPORATION_NAME,
BUSINESS_PARTNER_NUMBER,
IDENTIFICATION_NUMBER,
CORPORATION_ID,
COUNTRY,
case when not COUNTRY in ('US', 'CA', 'MX') and CUSTOMER_GROUP not ilike 'TEL Group' then 'Others'
    else REGION 
end                                                         as State_and_Province,
case when not COUNTRY in ('US', 'CA', 'MX') then 'Others'
    when COUNTRY = 'MX' then 'West'
    when COUNTRY = 'CA' then 'East'
    when US_STATE = 'TX' and CORPORATION_NAME ilike any ('CANON%', 'TOWER SEMI%', 'EVERSPIN%') then 'East'
    when US_STATE = 'AZ' and CORPORATION_NAME ilike any ('EVERSPIN%') then 'East'
    when US_STATE IN ('AZ', 'CA', 'CO', 'ID', 'KS', 'MO', 'NE', 'NV', 'NM', 'ND', 'OK', 'OR', 'SD', 'TX', 'UT', 'WA', 'WY') then 'West'
    else 'East' 
end                                                         as Sales_Region,
case when Sales_Account = 'Regional' then concat(Sales_Account, ' ', Sales_Region)
    else Sales_Account 
end                                                         as Sales_Account_Region
from {{ ref('GOLD__TEH_REVENUE_COGS__SAP_CUSTOMER') }}
),
TRANSFORM_DATA AS (
SELECT
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
	SHA2('hash_me') AS _ROW_HASH,
	SALES_ACCOUNT,
	CORPORATION_NAME,
	BUSINESS_PARTNER_NUMBER,
	IDENTIFICATION_NUMBER,
	CORPORATION_ID,
	COUNTRY,
	STATE_AND_PROVINCE,
	SALES_REGION,
	SALES_ACCOUNT_REGION

FROM SOURCE_DATA

)

,
TYPE_DATA AS (
SELECT
	CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
	CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
	SALES_ACCOUNT,
	CORPORATION_NAME,
	BUSINESS_PARTNER_NUMBER,
	IDENTIFICATION_NUMBER,
	CORPORATION_ID,
	COUNTRY,
	STATE_AND_PROVINCE,
	SALES_REGION,
	SALES_ACCOUNT_REGION
FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA