{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='MATERIAL_SUPPLIER',
    	transient=false
) }}

WITH ref_cte_DOCUMENT_SEGMENT_MATERIAL as (
    select * from {{ ref('SILVER__TMEA_QUALITY__DOCUMENT_SEGMENT_MATERIAL') }}
),

ref_cte_MATERIAL_DESCRIPTIONS as (
    select * from {{ ref('SILVER__TMEA_QUALITY__MATERIAL_DESCRIPTIONS') }}
),

ref_cte_VENDOR_MASTER as (
    select * from {{ ref('SILVER__TMEA_QUALITY__VENDOR_MASTER') }}
),



source_data as (
SELECT distinct
MSEG.material_number,
MATERIAL_DESCRIPTION,
vendor_account_number AS SUPPLIER_NUMBER,
name_1 AS SUPPLIER
FROM  ref_cte_document_segment_material    MSEG
JOIN ref_cte_VENDOR_MASTER    LFA1 ON MSEG.VENDOR_ACCOUNT_NUMBER = LFA1.ACCOUNT_NUMBER_OF_VENDOR_OR_CREDITOR
JOIN ref_cte_MATERIAL_DESCRIPTIONS    MAKT ON MSEG.MATERIAL_NUMBER = MAKT.MATERIAL_NUMBER
where mseg.plant = '0010'
and MSEG.material_number is not null 
and MSEG.material_number <> ''
and MSEG.material_number <> ' '
AND POSTING_DATE_IN_THE_DOCUMENT >= '20210301'
order by MSEG.material_number asc),

transform_data as (
select 
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
	SHA2('hash_me') as _ROW_HASH,
	MATERIAL_NUMBER,
	MATERIAL_DESCRIPTION,
	SUPPLIER_NUMBER,
	SUPPLIER
from source_data
),

type_data as (
select
	CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
	cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
	CAST(MATERIAL_NUMBER as VARCHAR(16777216)) as MATERIAL_NUMBER,
	CAST(MATERIAL_DESCRIPTION as VARCHAR(16777216)) as MATERIAL_DESCRIPTION,
	CAST(SUPPLIER_NUMBER as VARCHAR(16777216)) as SUPPLIER_NUMBER,
	CAST(SUPPLIER as VARCHAR(16777216)) as SUPPLIER
from transform_data 
)
select * from type_data