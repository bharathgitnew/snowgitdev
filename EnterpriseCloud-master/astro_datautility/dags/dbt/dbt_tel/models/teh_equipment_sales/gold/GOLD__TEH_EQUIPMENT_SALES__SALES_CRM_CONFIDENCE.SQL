{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='SALES_CRM_CONFIDENCE',
    	transient=false
) }}

WITH ref_cte_CRM_SALES_GLOBALOPTIONSETMETADATA as (
    select * from {{ ref('SILVER__TEH_EQUIPMENT_SALES__SALES_GLOBALOPTIONSETMETADATA') }}
),



source_data as (
SELECT
    RIGHT(Option, 1)+1                                                              AS Confidence_Order,
    LocalizedLabel                                                                  AS Booking_Confidence,
    CASE WHEN LocalizedLabel = '--' THEN '--'
        ELSE SUBSTRING(LocalizedLabel, 1, CHARINDEX(':', LocalizedLabel) - 2) END   AS Confidence_Short,
    Option                                                                      AS Option_Code,
    LocalizedLabelLanguageCode, 
    OptionSetName
FROM ref_cte_CRM_SALES_GLOBALOPTIONSETMETADATA
WHERE LocalizedLabelLanguageCode = 1033 
    AND OptionSetName = 'tel_sm_order_confidence'
),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        CONFIDENCE_ORDER,
        BOOKING_CONFIDENCE,
        CONFIDENCE_SHORT,
        OPTION_CODE,
        LOCALIZEDLABELLANGUAGECODE,
        OPTIONSETNAME
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(CONFIDENCE_ORDER as NUMBER(38,10)) as CONFIDENCE_ORDER,
        CAST(BOOKING_CONFIDENCE as VARCHAR(16777216)) as BOOKING_CONFIDENCE,
        CAST(CONFIDENCE_SHORT as VARCHAR(16777216)) as CONFIDENCE_SHORT,
        CAST(OPTION_CODE as NUMBER(38,0)) as OPTION_CODE,
        CAST(LOCALIZEDLABELLANGUAGECODE as NUMBER(38,0)) as LOCALIZEDLABELLANGUAGECODE,
        CAST(OPTIONSETNAME as VARCHAR(16777216)) as OPTIONSETNAME
from transform_data 
)
select * from type_data