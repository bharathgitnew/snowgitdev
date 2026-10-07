{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='ROUTES_TEXTS',
        unique_key = ['CLIENT',
    'LANGUAGE_KEY',
    'ROUTE'],
        transient=false
) }}

with source_data as (
    select
        MANDT as CLIENT,
		SPRAS as LANGUAGE_KEY,
		ROUTE as ROUTE,
		BEZEI as DESCRIPTION_OF_ROUTE,
		_CAPTUREDATETIME
    from {{ ref('BRONZE__TMEA_SUPPLY_CHAIN__SAPO_ROUTES_TEXTS') }}
),

transform_data as (
    select
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		_CAPTUREDATETIME,
        CLIENT,
		LANGUAGE_KEY,
		ROUTE,
		DESCRIPTION_OF_ROUTE
    from source_data
),

type_data as (
    select
		cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(CLIENT as VARCHAR) as CLIENT,
		cast(LANGUAGE_KEY as VARCHAR) as LANGUAGE_KEY,
		cast(ROUTE as VARCHAR) as ROUTE,
		cast(DESCRIPTION_OF_ROUTE as VARCHAR) as DESCRIPTION_OF_ROUTE
    from transform_data
)
select * from type_data