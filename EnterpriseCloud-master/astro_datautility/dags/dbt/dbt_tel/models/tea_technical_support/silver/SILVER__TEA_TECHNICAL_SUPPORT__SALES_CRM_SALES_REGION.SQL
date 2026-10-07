{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='SALES_CRM_SALES_REGION',
    	transient=false
) }}

WITH ref_cte_CRM_ACCOUNT as (
    select * from {{ ref('SILVER__TEA_TECHNICAL_SUPPORT__CRM_ACCOUNT') }}
),



source_data as (
select

    ACCOUNTNUMBER               as Account_Number,

    ADDRESS2_STATEORPROVINCE    as State_or_Province,

    case when ADDRESS2_STATEORPROVINCE = 'Texas' and COM_COMPANY_SHORT_E_NAME ilike any ('CANON%', 'TOWER SEMI%') then 'East'

        when ADDRESS2_STATEORPROVINCE IN ('Arizona', 'California', 'Colorado', 'Idaho', 'Kansas', 'Montana', 'Nebraska', 'Nevada', 'New Mexico', 'North Dakota', 'Oklahoma',

        'Oregon', 'South Dakota', 'Texas', 'Utah', 'Washington', 'Wyoming', 'Baja California', 'Baja California Sur', 'Chihuahua') then 'West'

        else 'East' end         as Sales_Region,

    COM_COMPANY_E_NAME          as Company_Name,

    COM_COMPANY_SHORT_E_NAME    as Company_Name_Short,

    ADDRESS2_COUNTRY            as Country,

    COM_ADDRESS2                as Address,

    STATECODE,

    STATUSCODE

from ref_cte_crm_ACCOUNT crm

where ADDRESS2_COUNTRY in ('USA', 'Canada', 'Mexico')

    and not ADDRESS2_STATEORPROVINCE in ('Alaska', 'Hawaii')

    and STATECODE = 0

),

transform_data as (
select ACCOUNT_NUMBER,
	STATE_OR_PROVINCE,
	SALES_REGION,
	COMPANY_NAME,
	COMPANY_NAME_SHORT,
	COUNTRY,
	ADDRESS,
	STATECODE,
	STATUSCODE,
	'{{ invocation_id }}' AS AUDIT_LOG_ID
from source_data
),

type_data as (
select
	CAST(ACCOUNT_NUMBER as VARCHAR(16777216)) as ACCOUNT_NUMBER,
	CAST(STATE_OR_PROVINCE as VARCHAR(16777216)) as STATE_OR_PROVINCE,
	CAST(SALES_REGION as VARCHAR(16777216)) as SALES_REGION,
	CAST(COMPANY_NAME as VARCHAR(16777216)) as COMPANY_NAME,
	CAST(COMPANY_NAME_SHORT as VARCHAR(16777216)) as COMPANY_NAME_SHORT,
	CAST(COUNTRY as VARCHAR(16777216)) as COUNTRY,
	CAST(ADDRESS as VARCHAR(16777216)) as ADDRESS,
	CAST(STATECODE as NUMBER(38,0)) as STATECODE,
	CAST(STATUSCODE as NUMBER(38,0)) as STATUSCODE,
	CAST(AUDIT_LOG_ID as VARCHAR(128)) as AUDIT_LOG_ID
from transform_data 
)
select * from type_data