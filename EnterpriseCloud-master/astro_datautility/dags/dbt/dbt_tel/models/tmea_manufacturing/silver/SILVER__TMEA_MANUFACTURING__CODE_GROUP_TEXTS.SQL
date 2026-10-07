{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='CODE_GROUP_TEXTS',
        unique_key = ['CLIENT',
    'CATALOG',
    'CODE_GROUP',
    'LANGUAGE_KEY'],
        transient=false
) }}

with source_data as (
    select
        MANDANT as CLIENT,
		KATALOGART as CATALOG,
		CODEGRUPPE as CODE_GROUP,
		SPRACHE as LANGUAGE_KEY,
		KURZTEXT as SHORT_DESCRIPTION_OF_THE_CODE_GROUP,
		LTEXTV as LONG_TEXT_EXISTS_FOR_THE_CODE_GROUP,
		INAKTIV as STATUS_OF_CODE_GROUP_OR_CODE_RECORD,
		_CAPTUREDATETIME
    from {{ ref('BRONZE__TMEA_MANUFACTURING__SAPO_CODE_GROUP_TEXTS') }}
),

transform_data as (
    select
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		_CAPTUREDATETIME,
        CLIENT,
		CATALOG,
		CODE_GROUP,
		LANGUAGE_KEY,
		SHORT_DESCRIPTION_OF_THE_CODE_GROUP,
		LONG_TEXT_EXISTS_FOR_THE_CODE_GROUP,
		STATUS_OF_CODE_GROUP_OR_CODE_RECORD,

    from source_data
),

type_data as (
    select
		cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(CLIENT as VARCHAR) as CLIENT,
		cast(CATALOG as VARCHAR) as CATALOG,
		cast(CODE_GROUP as VARCHAR) as CODE_GROUP,
		cast(LANGUAGE_KEY as VARCHAR) as LANGUAGE_KEY,
		cast(SHORT_DESCRIPTION_OF_THE_CODE_GROUP as VARCHAR) as SHORT_DESCRIPTION_OF_THE_CODE_GROUP,
		cast(LONG_TEXT_EXISTS_FOR_THE_CODE_GROUP as VARCHAR) as LONG_TEXT_EXISTS_FOR_THE_CODE_GROUP,
		cast(STATUS_OF_CODE_GROUP_OR_CODE_RECORD as VARCHAR) as STATUS_OF_CODE_GROUP_OR_CODE_RECORD
    from transform_data
)
select * from type_data