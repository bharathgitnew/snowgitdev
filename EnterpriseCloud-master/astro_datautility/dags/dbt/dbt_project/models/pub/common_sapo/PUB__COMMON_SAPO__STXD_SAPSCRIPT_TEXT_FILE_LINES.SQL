{{ config(
        materialized='view',
         alias='STXD_SAPSCRIPT_TEXT_FILE_LINES',
         transient=false
) }}

with source_data as (
    select
        CLIENT,
		CHAR02_DATA_ELEMENT_FOR_SYST,
		TEXTS_APPLICATION_OBJECT,
		NAME,
		TEXT_ID,
		LANGUAGE_KEY,
		BIN1_DATA_ELEMENT_FOR_SYST,
		BIN2_DATA_ELEMENT_FOR_SYST,
		SAPSCRIPT_LONG_RAW_FIELD_FOR_TABLE_STXL,
		_CAPTUREDATETIME
    from {{ ref('COMMON__SAPO__STXD_SAPSCRIPT_TEXT_FILE_LINES') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data