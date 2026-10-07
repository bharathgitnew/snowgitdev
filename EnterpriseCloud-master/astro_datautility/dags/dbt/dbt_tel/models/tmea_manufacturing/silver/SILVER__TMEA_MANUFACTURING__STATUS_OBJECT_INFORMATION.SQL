{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='STATUS_OBJECT_INFORMATION',
        unique_key = ['CLIENT',
    'OBJECT_NUMBER'],
        transient=false
) }}

with source_data as (
    select
        MANDT as CLIENT,
		OBJNR as OBJECT_NUMBER,
		OBTYP as OBJECT_CATEGORY,
		STSMA as STATUS_PROFILE,
		CHGKZ as INDICATOR_CHANGE_DOCUMENTS_ARE_ACTIVE,
		CHGNR as CHANGE_NUMBER,
		DATAAGING as DATA_FILTER_VALUE_FOR_DATA_AGING,
		_CAPTUREDATETIME
    from {{ ref('BRONZE__TMEA_MANUFACTURING__SAPO_STATUS_OBJECT_INFORMATION') }}
),

transform_data as (
    select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
		_CAPTUREDATETIME,
        CLIENT,
		OBJECT_NUMBER,
		OBJECT_CATEGORY,
		STATUS_PROFILE,
		INDICATOR_CHANGE_DOCUMENTS_ARE_ACTIVE,
		CHANGE_NUMBER,
		try_to_date(DATA_FILTER_VALUE_FOR_DATA_AGING, 'YYYYMMDD') as DATA_FILTER_VALUE_FOR_DATA_AGING
    from source_data
),

type_data as (
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(CLIENT as VARCHAR) as CLIENT,
		cast(OBJECT_NUMBER as VARCHAR) as OBJECT_NUMBER,
		cast(OBJECT_CATEGORY as VARCHAR) as OBJECT_CATEGORY,
		cast(STATUS_PROFILE as VARCHAR) as STATUS_PROFILE,
		cast(INDICATOR_CHANGE_DOCUMENTS_ARE_ACTIVE as VARCHAR) as INDICATOR_CHANGE_DOCUMENTS_ARE_ACTIVE,
		cast(CHANGE_NUMBER as VARCHAR) as CHANGE_NUMBER,
		cast(DATA_FILTER_VALUE_FOR_DATA_AGING as DATE) as DATA_FILTER_VALUE_FOR_DATA_AGING
    from transform_data
)
select * from type_data