{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='SALES_CRM_SALES_REGION',
    	transient=false
) }}

WITH ref_cte_CRM_ACCOUNT as (
    select * from {{ ref('SILVER__TEH_SALES_TO_INSTALLATION__ACCOUNT') }}
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
select 
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
	SHA2('hash_me') AS _ROW_HASH,
	ACCOUNT_NUMBER,
	STATE_OR_PROVINCE,
	SALES_REGION,
	COMPANY_NAME,
	COMPANY_NAME_SHORT,
	COUNTRY,
	ADDRESS,
	STATECODE,
	STATUSCODE
from source_data
),

type_data as (
select
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	ACCOUNT_NUMBER,
	STATE_OR_PROVINCE,
	SALES_REGION,
	COMPANY_NAME,
	COMPANY_NAME_SHORT,
	COUNTRY,
	ADDRESS,
	CAST(STATECODE as NUMBER(38,0)) as STATECODE,
	CAST(STATUSCODE as NUMBER(38,0)) as STATUSCODE
from transform_data 
)
select * from type_data