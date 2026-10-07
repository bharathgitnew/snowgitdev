{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='REJECTION_REASONS_FOR_SALES_DOCUMENTS_TEXTS',
        unique_key = ['CLIENT',
    'LANGUAGE_KEY',
    'REASON_FOR_REJECTION_OF_QUOTATIONS_AND_SALES_ORDERS'],
        transient=false
) }}

with source_data as (
    select
        MANDT as CLIENT,
		SPRAS as LANGUAGE_KEY,
		ABGRU as REASON_FOR_REJECTION_OF_QUOTATIONS_AND_SALES_ORDERS,
		BEZEI as DESCRIPTION,
		_CAPTUREDATETIME
    from {{ ref('BRONZE__TMEA_MANUFACTURING__SAPO_REJECTION_REASONS_FOR_SALES_DOCUMENTS_TEXTS') }}
),

transform_data as (
    select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
		_CAPTUREDATETIME,
        CLIENT,
		LANGUAGE_KEY,
		REASON_FOR_REJECTION_OF_QUOTATIONS_AND_SALES_ORDERS,
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
		cast(REASON_FOR_REJECTION_OF_QUOTATIONS_AND_SALES_ORDERS as VARCHAR) as REASON_FOR_REJECTION_OF_QUOTATIONS_AND_SALES_ORDERS,
		cast(DESCRIPTION as VARCHAR) as DESCRIPTION
    from transform_data
)
select * from type_data