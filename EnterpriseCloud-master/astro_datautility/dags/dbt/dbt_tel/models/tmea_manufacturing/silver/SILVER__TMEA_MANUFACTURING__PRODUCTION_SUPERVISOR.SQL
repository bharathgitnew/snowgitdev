{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='PRODUCTION_SUPERVISOR',
        unique_key = ['CLIENT',
    'PLANT',
    'PRODUCTION_SUPERVISOR'],
        transient=false
) }}

with source_data as (
    select
        MANDT as CLIENT,
		WERKS as PLANT,
		FEVOR as PRODUCTION_SUPERVISOR,
		TXT as DESCRIPTION_OF_PRODUCTION_SUPERVISOR,
		SFCPF as PRODUCTION_SCHEDULING_PROFILE,
		_CAPTUREDATETIME
    from {{ ref('BRONZE__TMEA_MANUFACTURING__SAPO_PRODUCTION_SUPERVISOR') }}
),

transform_data as (
    select

		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		_CAPTUREDATETIME,
        CLIENT,
		PLANT,
		PRODUCTION_SUPERVISOR,
		DESCRIPTION_OF_PRODUCTION_SUPERVISOR,
		PRODUCTION_SCHEDULING_PROFILE

    from source_data
),

type_data as (
    select
		cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(CLIENT as VARCHAR) as CLIENT,
		cast(PLANT as VARCHAR) as PLANT,
		cast(PRODUCTION_SUPERVISOR as VARCHAR) as PRODUCTION_SUPERVISOR,
		cast(DESCRIPTION_OF_PRODUCTION_SUPERVISOR as VARCHAR) as DESCRIPTION_OF_PRODUCTION_SUPERVISOR,
		cast(PRODUCTION_SCHEDULING_PROFILE as VARCHAR) as PRODUCTION_SCHEDULING_PROFILE
		
		
    from transform_data
)
select * from type_data