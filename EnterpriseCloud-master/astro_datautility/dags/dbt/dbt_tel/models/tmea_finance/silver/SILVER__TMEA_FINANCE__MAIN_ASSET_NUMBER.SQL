{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='MAIN_ASSET_NUMBER',
        unique_key = ['CLIENT',
    'COMPANY_CODE',
    'MAIN_ASSET_NUMBER'],
        transient=false
) }}

with source_data as (
    select
        MANDT as CLIENT,
        BUKRS as COMPANY_CODE,
        ANLN1 as MAIN_ASSET_NUMBER,
        LUNTN as LAST_SUBNUMBER_ASSIGNED_TO_THIS_MAIN_NUMBER,
        LANEP as LAST_LINE_ITEM_NUMBER_ASSIGNED,
        ANUPD as INDICATOR_TYPE_OF_CHANGE_TO_TABLE,
        FUNTN as FIRST_SUBNUMBER_ASSIGNED,
        ANLHTXT as ASSET_MAIN_NUMBER_TEXT,
        _CAPTUREDATETIME
    from {{ ref('BRONZE__TMEA_FINANCE__SAPO_MAIN_ASSET_NUMBER') }}
),

transform_data as (
    select
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		_CAPTUREDATETIME,
        CLIENT,
        COMPANY_CODE,
        MAIN_ASSET_NUMBER,
        LAST_SUBNUMBER_ASSIGNED_TO_THIS_MAIN_NUMBER,
        LAST_LINE_ITEM_NUMBER_ASSIGNED,
        INDICATOR_TYPE_OF_CHANGE_TO_TABLE,
        FIRST_SUBNUMBER_ASSIGNED,
        ASSET_MAIN_NUMBER_TEXT
    from source_data
),

type_data as (
    select
		cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        CLIENT,
        COMPANY_CODE,
        MAIN_ASSET_NUMBER,
        LAST_SUBNUMBER_ASSIGNED_TO_THIS_MAIN_NUMBER,
        LAST_LINE_ITEM_NUMBER_ASSIGNED,
        INDICATOR_TYPE_OF_CHANGE_TO_TABLE,
        FIRST_SUBNUMBER_ASSIGNED,
        ASSET_MAIN_NUMBER_TEXT
    from transform_data
)
select * from type_data