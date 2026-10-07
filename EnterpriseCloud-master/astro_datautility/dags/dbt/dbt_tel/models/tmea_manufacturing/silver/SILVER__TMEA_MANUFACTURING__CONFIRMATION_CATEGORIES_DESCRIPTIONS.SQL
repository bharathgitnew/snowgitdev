{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='CONFIRMATION_CATEGORIES_DESCRIPTIONS',
        unique_key = ['CLIENT','LANGUAGE_KEY','CONFIRMATION_CATEGORY'],
        transient=false
) }}

with source_data as (
    select
        MANDT AS CLIENT,
        SPRAS AS LANGUAGE_KEY,
        EBTYP AS CONFIRMATION_CATEGORY,
        EBTXT AS CONFIRMATION_CATEGORY_DESCRIPTION,
        EBUEB AS HEADING_FOR_QUANTITY_OF_CONFIRMATION_CATEGORY,
        _CAPTUREDATETIME
    from {{ ref('BRONZE__TMEA_MANUFACTURING__SAPO_CONFIRMATION_CATEGORIES_DESCRIPTIONS') }}
),

transform_data as (
    select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
		_CAPTUREDATETIME,
        CLIENT,
        LANGUAGE_KEY,
        CONFIRMATION_CATEGORY,
        CONFIRMATION_CATEGORY_DESCRIPTION,
        HEADING_FOR_QUANTITY_OF_CONFIRMATION_CATEGORY
    from source_data
),

type_data as (
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        CLIENT,
        LANGUAGE_KEY,
        CONFIRMATION_CATEGORY,
        CONFIRMATION_CATEGORY_DESCRIPTION,
        HEADING_FOR_QUANTITY_OF_CONFIRMATION_CATEGORY
    from transform_data
)
select * from type_data