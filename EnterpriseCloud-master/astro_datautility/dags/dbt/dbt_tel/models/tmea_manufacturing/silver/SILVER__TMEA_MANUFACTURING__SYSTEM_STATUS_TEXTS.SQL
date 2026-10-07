{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='SYSTEM_STATUS_TEXTS',
        unique_key = ['SYSTEM_STATUS',
    'LANGUAGE_KEY'],
        transient=false
) }}

with source_data as (
    select
        ISTAT as SYSTEM_STATUS,
		SPRAS as LANGUAGE_KEY,
		TXT04 as INDIVIDUAL_STATUS_OF_AN_OBJECT_SHORT_FORM,
		TXT30 as OBJECT_STATUS,
		_CAPTUREDATETIME
    from {{ ref('BRONZE__TMEA_MANUFACTURING__SAPO_SYSTEM_STATUS_TEXTS') }}
),

transform_data as (
    select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
		_CAPTUREDATETIME,
        SYSTEM_STATUS,
		LANGUAGE_KEY,
		INDIVIDUAL_STATUS_OF_AN_OBJECT_SHORT_FORM,
		OBJECT_STATUS
    from source_data
),

type_data as (
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(SYSTEM_STATUS as VARCHAR) as SYSTEM_STATUS,
		cast(LANGUAGE_KEY as VARCHAR) as LANGUAGE_KEY,
		cast(INDIVIDUAL_STATUS_OF_AN_OBJECT_SHORT_FORM as VARCHAR) as INDIVIDUAL_STATUS_OF_AN_OBJECT_SHORT_FORM,
		cast(OBJECT_STATUS as VARCHAR) as OBJECT_STATUS
    from transform_data
)
select * from type_data