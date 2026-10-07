{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='STANDARD_ACCOUNTS',
        unique_key = ['CLIENT',
    'CHART_OF_ACCOUNTS',
    'TRANSACTION_KEY',
    'VALUATION_GROUPING_CODE',
    'ACCOUNT_MODIFICATION',
    'VALUATION_CLASS'],
        transient=false
) }}

with source_data as (
    SELECT
		_CAPTUREDATETIME,
        MANDT as CLIENT,
        KTOPL as CHART_OF_ACCOUNTS,
        KTOSL as TRANSACTION_KEY,
        BWMOD as VALUATION_GROUPING_CODE,
        KOMOK as ACCOUNT_MODIFICATION,
        BKLAS as VALUATION_CLASS,
        KONTS as GL_ACCOUNT_NUMBER_1,
        KONTH as GL_ACCOUNT_NUMBER_2
    from {{ ref('BRONZE__TMEA_SUPPLY_CHAIN__SAPO_STANDARD_ACCOUNTS') }}
),

transform_data as (
    select
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		_CAPTUREDATETIME,
        CLIENT,
        CHART_OF_ACCOUNTS,
        TRANSACTION_KEY,
        VALUATION_GROUPING_CODE,
        ACCOUNT_MODIFICATION,
        VALUATION_CLASS,
        GL_ACCOUNT_NUMBER_1,
        GL_ACCOUNT_NUMBER_2
    from source_data
),

type_data as (
    select
		cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        CLIENT,
        CHART_OF_ACCOUNTS,
        TRANSACTION_KEY,
        VALUATION_GROUPING_CODE,
        ACCOUNT_MODIFICATION,
        VALUATION_CLASS,
        GL_ACCOUNT_NUMBER_1,
        GL_ACCOUNT_NUMBER_2
    from transform_data
)

select * from type_data