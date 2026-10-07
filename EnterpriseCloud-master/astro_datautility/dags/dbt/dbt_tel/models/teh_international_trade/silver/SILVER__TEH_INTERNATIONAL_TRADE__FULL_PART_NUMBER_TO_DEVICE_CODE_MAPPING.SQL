{{ config(
          materialized='tel_incremental',
          incremental_strategy='insert_overwrite',
          alias='FULL_PART_NUMBER_TO_DEVICE_CODE_MAPPING',
	    transient=false    
) }}

with source_data as (
    SELECT 
        MATNR,
        ZZDEVI
    FROM {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPAPI_ZCDV_T_CMTU017_MARA') }}   	
),
transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        MATNR as FULL_PART_NUMBER,
        ZZDEVI as DEVICE_CODE
    from source_data
),
type_data as (
    SELECT
            cast(_AUDIT_LOG_ID AS varchar(128)) AS _AUDIT_LOG_ID,
            cast(_ROW_HASH AS varchar(128)) AS _ROW_HASH,
            FULL_PART_NUMBER,
            DEVICE_CODE
    FROM transform_data
)
select * from type_data