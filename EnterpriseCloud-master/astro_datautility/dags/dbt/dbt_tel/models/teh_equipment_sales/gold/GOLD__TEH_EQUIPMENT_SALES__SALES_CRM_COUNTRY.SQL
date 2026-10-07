{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='SALES_CRM_COUNTRY',
    	transient=false
) }}

WITH ref_cte_CRM_SALES_COM_COUNTRYMASTER as (
    select * from {{ ref('SILVER__TEH_EQUIPMENT_SALES__SALES_COM_COUNTRYMASTER') }}
),



source_data as (
SELECT
    Id                              AS Country_ID,
    com_name                        AS Country,
    tel_com_country_code_2_digit    AS Country_Code    
FROM ref_cte_CRM_SALES_COM_COUNTRYMASTER
),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        COUNTRY_ID,
        COUNTRY,
        COUNTRY_CODE
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(COUNTRY_ID as VARCHAR(16777216)) as COUNTRY_ID,
        CAST(COUNTRY as VARCHAR(16777216)) as COUNTRY,
        CAST(COUNTRY_CODE as VARCHAR(16777216)) as COUNTRY_CODE
from transform_data 
)
select * from type_data