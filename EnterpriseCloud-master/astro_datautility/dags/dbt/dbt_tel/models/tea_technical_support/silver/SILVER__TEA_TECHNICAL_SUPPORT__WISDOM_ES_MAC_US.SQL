{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='WISDOM_ES_MAC_US'
) }}

with source_data as 
( 
    SELECT
      _FILEDATE,
      LOCAL_FE_STATION,
      CUSTOMER_CODE,
      COMPANY_NAME,
      LOCATION_NAME,
      CUSTOMER_CODE_9,
      SALES_STATION,
      BU_NAME,
      MACHINE_ID,
      MACHINE_SN,
      PARENT_SN,
      CUSTOMER_TOOL_ID,
      MODEL_NAME,
      MACHINE_WARRANTY_STATUS,
      SYSTEM_NAME,
      PROCESS_NAME,
      WAFER_SIZE,
      SWLH_MODEL,
      POSITION,
      REGION_NAME,
      SUBSIDIARY_NAME
    FROM  {{ ref('BRONZE__TEA_TECHNICAL_SUPPORT__WISDOM_WISDOM_ES_MAC_US') }}
)

,transform_data as 
(
    SELECT
        _FILEDATE as _FILEDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        LOCAL_FE_STATION as LOCAL_FE_STATION,
        CUSTOMER_CODE as CUSTOMER_CODE,
        COMPANY_NAME as COMPANY_NAME,
        LOCATION_NAME as LOCATION_NAME,
        CUSTOMER_CODE_9 as CUSTOMER_CODE_9,
        SALES_STATION as SALES_STATION,
        BU_NAME as BU_NAME,
        MACHINE_ID::NUMBER as MACHINE_ID,
        MACHINE_SN as MACHINE_SN,
        PARENT_SN as PARENT_SN,
        CUSTOMER_TOOL_ID as CUSTOMER_TOOL_ID,
        MODEL_NAME as MODEL_NAME,
        MACHINE_WARRANTY_STATUS as MACHINE_WARRANTY_STATUS,
        SYSTEM_NAME as SYSTEM_NAME,
        PROCESS_NAME as PROCESS_NAME,
        WAFER_SIZE as WAFER_SIZE,
        SWLH_MODEL as SWLH_MODEL,
        POSITION as POSITION,
        REGION_NAME as REGION_NAME,
        SUBSIDIARY_NAME as SUBSIDIARY_NAME
    FROM source_data 
),
type_data as 
(
    SELECT
        _FILEDATE,
        _AUDIT_LOG_ID,
        _ROW_HASH,
        LOCAL_FE_STATION,
        CUSTOMER_CODE,
        COMPANY_NAME,
        LOCATION_NAME,
        CUSTOMER_CODE_9,
        SALES_STATION,
        BU_NAME,
        MACHINE_ID,
        MACHINE_SN,
        PARENT_SN,
        CUSTOMER_TOOL_ID,
        MODEL_NAME,
        MACHINE_WARRANTY_STATUS,
        SYSTEM_NAME,
        PROCESS_NAME,
        WAFER_SIZE,
        SWLH_MODEL,
        POSITION,
        REGION_NAME,
        SUBSIDIARY_NAME
    FROM transform_data 
)
select * from type_data