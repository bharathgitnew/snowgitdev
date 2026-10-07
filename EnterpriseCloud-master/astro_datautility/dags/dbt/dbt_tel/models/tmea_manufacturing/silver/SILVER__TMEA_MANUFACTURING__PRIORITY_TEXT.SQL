{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='PRIORITY_TEXT',
        unique_key = ['CLIENT',
    'LANGUAGE_KEY',
    'PRIORITY_TYPE',
    'PRIORITY'],
        transient=false
) }}

with source_data as (
    select
        MANDT as CLIENT,
		SPRAS as LANGUAGE_KEY,
		ARTPR as PRIORITY_TYPE,
		PRIOK as PRIORITY,
		PRIOKX as PRIORITY_TEXT,
		_CAPTUREDATETIME
    from {{ ref('BRONZE__TMEA_MANUFACTURING__SAPO_PRIORITY_TEXT') }}
),

transform_data as (
    select
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		_CAPTUREDATETIME,
        CLIENT,
		LANGUAGE_KEY,
		PRIORITY_TYPE,
		PRIORITY,
		PRIORITY_TEXT		
		
    from source_data
),

type_data as (
    select
		cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(CLIENT as VARCHAR) as CLIENT,
		cast(LANGUAGE_KEY as VARCHAR) as LANGUAGE_KEY,
		cast(PRIORITY_TYPE as VARCHAR) as PRIORITY_TYPE,
		cast(PRIORITY as VARCHAR) as PRIORITY,
		cast(PRIORITY_TEXT as VARCHAR) as PRIORITY_TEXT		

    from transform_data
)
select * from type_data