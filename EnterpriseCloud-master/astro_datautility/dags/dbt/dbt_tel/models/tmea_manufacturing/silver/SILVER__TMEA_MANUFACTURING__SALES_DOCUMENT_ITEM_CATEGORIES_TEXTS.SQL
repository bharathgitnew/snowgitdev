{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='SALES_DOCUMENT_ITEM_CATEGORIES_TEXTS',
        unique_key = ['CLIENT',
    'LANGUAGE_KEY',
    'SALES_DOCUMENT_ITEM_CATEGORY'],
        transient=false
) }}

with source_data as (
    select
        MANDT as CLIENT,
		SPRAS as LANGUAGE_KEY,
		PSTYV as SALES_DOCUMENT_ITEM_CATEGORY,
		VTEXT as DESCRIPTION,
		_CAPTUREDATETIME
    from {{ ref('BRONZE__TMEA_MANUFACTURING__SAPO_SALES_DOCUMENT_ITEM_CATEGORIES_TEXTS') }}
),

transform_data as (
    select
        
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
        _CAPTUREDATETIME,
        CLIENT,
		LANGUAGE_KEY,
		SALES_DOCUMENT_ITEM_CATEGORY,
		DESCRIPTION
		
    from source_data
),

type_data as (
    select
        
		cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(CLIENT as VARCHAR) as CLIENT,
		cast(LANGUAGE_KEY as VARCHAR) as LANGUAGE_KEY,
		cast(SALES_DOCUMENT_ITEM_CATEGORY as VARCHAR) as SALES_DOCUMENT_ITEM_CATEGORY,
		cast(DESCRIPTION as VARCHAR) as DESCRIPTION
		
    from transform_data
)
select * from type_data