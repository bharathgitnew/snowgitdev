{{ config(
      materialized='view',
      alias='SERIAL_NUMBERS',
      transient=false
) }}


with source_data as (
    SELECT 
        SERIAL_NUMBER_ID,
        NCDR_NUMBER,
        MACHINE_SERIAL_NUMBER,
        MACHINE_STATUS,
        MACHINE_SYSTEM_TYPE,
        MACHINE_EXIT_FACTORY_DATE,
        MACHINE_SYSTEM_ACCEPTANCE_DATE,
        MACHINE_STARTUP_START_DATE,
        MACHINE_WARRANTY_START_DATE,
        MACHINE_WARRANTY_EXPIRE_DATE,
        WARRANTY_STATUS_ID,
        OBJECT_NUMBER,
        SUPPLIER_CD,
        DEFECTIVE_PORTION_ID,
        FRF_FLAG,
        MAC_HIST_REASON_ID,
        MAC_HIST_REASON_NAME_J,
        MAC_HIST_REASON_NAME,
        PROJECT_NO
    FROM {{ ref('COMMON__NOW__SERIAL_NUMBERS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data