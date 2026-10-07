{{ config(
        materialized='view',
         alias='ABAP_4_VARIANT_STORAGE',
         transient=false
) }}

with source_data as (
    select
        CLIENT,
		RELATION_ID,
		ABAP_PROGRAM_NAME_IN_VARIANT_KEY,
		ABAP_NAME_OF_VARIANT_WITHOUT_PROGRAM_NAME,
		NEXT_RECORD_COUNTER_IN_EXPORTIMPORT_DATA_TABLES,
		ABAP_DATE_OF_A_VARIANT,
		ABAP_TIME_OF_A_VARIANT,
		ABAP_PROGRAM_VERSION_NUMBER,
		BIN2_DATA_ELEMENT_FOR_SYST,
		CONTENTS_OF_VARIANT,
		_CAPTUREDATETIME
    from {{ ref('COMMON__SAPO__ABAP_4_VARIANT_STORAGE') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data