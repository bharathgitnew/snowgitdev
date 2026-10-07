{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='TPL_UPS_Inventory_File_US'
) }}

with source_data as (
    SELECT 
        Storage_Location,
        Part_Number,
        WMS_Batch_Number,
        Serial_Number,
        Quantity,
        Date_of_Extract,
        _filename,
        _filedate,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
    FROM {{ source("THREEPL", "TPL_UPS_INVENTORY_FILE_US") }}
	WHERE date_of_extract=(select max(date_of_extract) from {{ source("THREEPL", "TPL_UPS_INVENTORY_FILE_US") }})
)

,transform_data as
(
    SELECT
        Storage_Location as STORAGE_LOCATION,
        Part_Number as PART_NUMBER,
        WMS_Batch_Number as WMS_BATCH_NUMBER,
        Serial_Number as SERIAL_NUMBER,
        TRY_TO_NUMBER(source_data.Quantity,38,0) as QUANTITY,
        Date_of_Extract as DATE_OF_EXTRACT,
        _filename as _FILENAME,
        _filedate as _FILEDATE,
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
        CAST(QUANTITY AS NUMBER(38,0)) AS QUANTITY,
        DATE_OF_EXTRACT,
        _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE
    FROM transform_data
)

SELECT * FROM type_data