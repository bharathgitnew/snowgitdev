{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='STORAGE_TYPE_DESCRIPTIONS',
        unique_key = ['CLIENT',
    'LANGUAGE_KEY',
    'WAREHOUSE_NUMBER_WAREHOUSE_COMPLEX',
    'STORAGE_TYPE'],
        transient=false
) }}

with source_data as (
    select
        MANDT as CLIENT,
		SPRAS as LANGUAGE_KEY,
		LGNUM as WAREHOUSE_NUMBER_WAREHOUSE_COMPLEX,
		LGTYP as STORAGE_TYPE,
		LTYPT as NAME_OF_STORAGE_TYPE,
		_CAPTUREDATETIME
    from {{ ref('BRONZE__TMEA_SUPPLY_CHAIN__SAPO_STORAGE_TYPE_DESCRIPTIONS') }}
),

transform_data as (
    select
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		_CAPTUREDATETIME,
        CLIENT,
		LANGUAGE_KEY,
		WAREHOUSE_NUMBER_WAREHOUSE_COMPLEX,
		STORAGE_TYPE,
		NAME_OF_STORAGE_TYPE
    from source_data
),

type_data as (
    select
		cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(CLIENT as VARCHAR) as CLIENT,
		cast(LANGUAGE_KEY as VARCHAR) as LANGUAGE_KEY,
		cast(WAREHOUSE_NUMBER_WAREHOUSE_COMPLEX as VARCHAR) as WAREHOUSE_NUMBER_WAREHOUSE_COMPLEX,
		cast(STORAGE_TYPE as VARCHAR) as STORAGE_TYPE,
		cast(NAME_OF_STORAGE_TYPE as VARCHAR) as NAME_OF_STORAGE_TYPE
    from transform_data
)
select * from type_data