/************
Model file generated from dbtGeneratePubViews: 03.09.2022.17.40.39"
*************/

{{ config(
      materialized='view',
      alias='TBL_PROCESSOR',
      transient=false
) }}

with source_data as (
    SELECT
        WIN32_PROCESSORID,
        ASSET_ID,
        ADDRESS_WIDTH,
        ARCHITECTURE,
        AVAILABILITY,
        CAPTION,
        CPU_STATUS,
        DATA_WIDTH,
        DEVICE_ID,
        EXT_CLOCK,
        FAMILY,
        L2_CACHE_SIZE,
        L2_CACHE_SPEED,
        LEVEL,
        MANUFACTURER,
        MAX_CLOCK_SPEED,
        NAME,
        NUMBER_OF_CORES,
        NUMBER_OF_LOGICAL_PROCESSORS,
        PROCESSOR_ID,
        PROCESSOR_TYPE,
        REVISION,
        SOCKET_DESIGNATION,
        STEPPING,
        UNIQUE_ID,
        UPGRADE_METHOD,
        VERSION,
        VOLTAGE_CAPS,
        LAST_CHANGED,
        _FILEDATE
    from {{ ref('ODS__LANSWEEPER__TBL_PROCESSOR') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data