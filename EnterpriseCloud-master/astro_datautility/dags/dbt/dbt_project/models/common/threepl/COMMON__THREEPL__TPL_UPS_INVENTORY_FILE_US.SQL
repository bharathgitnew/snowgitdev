{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='TPL_UPS_Inventory_File_US'
) }}


with source_data as (
    SELECT
    STORAGE_LOCATION,
    PART_NUMBER,
    WMS_BATCH_NUMBER,
    SERIAL_NUMBER,
    QUANTITY,
    DATE_OF_EXTRACT,
    _FILENAME,
    _FILEDATE,
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH
    FROM {{ ref('ODS__THREEPL__TPL_UPS_INVENTORY_FILE_US') }}
)

,transform_data as 
(
    SELECT
    STORAGE_LOCATION,
    PART_NUMBER,
    WMS_BATCH_NUMBER,
    SERIAL_NUMBER,
    QUANTITY,
    DATE_OF_EXTRACT,
    _FILENAME,
    _FILEDATE,
    _AUDIT_LOG_ID,
    _ROW_HASH
    FROM source_data 
)    

,type_data as 
(
    SELECT
    CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
    CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
    STORAGE_LOCATION,
    PART_NUMBER,
    WMS_BATCH_NUMBER,
    SERIAL_NUMBER,
    QUANTITY,
    DATE_OF_EXTRACT,
    _FILENAME,
    _FILEDATE
    FROM transform_data 
)

SELECT * FROM type_data