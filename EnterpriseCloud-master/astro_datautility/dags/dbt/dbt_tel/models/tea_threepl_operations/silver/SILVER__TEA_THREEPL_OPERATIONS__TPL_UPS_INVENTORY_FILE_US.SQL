{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TPL_UPS_INVENTORY_FILE_US'
) }}


with source_data as (
    SELECT
    _FILENAME,
    _FILEDATE,
    STORAGE_LOCATION,
    PART_NUMBER,
    WMS_BATCH_NUMBER,
    SERIAL_NUMBER,
    QUANTITY,
    DATE_OF_EXTRACT
    FROM {{ ref('BRONZE__TEA_THREEPL_OPERATIONS__THREEPL_TPL_UPS_INVENTORY_FILE_US') }}
)

,transform_data as 
(
    SELECT
    _FILENAME,
    _FILEDATE,
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
    STORAGE_LOCATION,
    PART_NUMBER,
    WMS_BATCH_NUMBER,
    SERIAL_NUMBER,
    QUANTITY,
    DATE_OF_EXTRACT
    FROM source_data 
)    

,type_data as 
(
    SELECT
    _FILENAME,
    _FILEDATE,
    CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
    CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
    STORAGE_LOCATION,
    PART_NUMBER,
    WMS_BATCH_NUMBER,
    SERIAL_NUMBER,
    QUANTITY,
    DATE_OF_EXTRACT
    FROM transform_data 
)

SELECT * FROM type_data