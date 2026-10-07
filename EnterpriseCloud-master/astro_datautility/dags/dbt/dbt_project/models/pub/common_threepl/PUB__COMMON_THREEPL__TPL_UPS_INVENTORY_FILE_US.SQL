{{ config(
      materialized='view',
      alias='TPL_UPS_Inventory_File_US',
      transient=false
) }}

with source_data as 
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
    FROM {{ ref('COMMON__THREEPL__TPL_UPS_INVENTORY_FILE_US') }}
)

,transform_data AS
(
    select * from source_data
)

    select * from transform_data