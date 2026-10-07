/************
Model file generated from dbtGeneratePubViews: 03.09.2022.17.40.39"
*************/

{{ config(
      materialized='view',
      alias='TBL_COMPUTER_SYSTEM',
      transient=false
) }}

with source_data as (
    SELECT
        COMPUTER_SYSTEM_ID,
        ASSET_ID,
        ADMIN_PASSWORD_STATUS,
        AUTOMATIC_RESET_BOOT_OPTION,
        AUTOMATIC_RESET_CAPABILITY,
        BOOT_OPTION_ON_LIMIT,
        BOOT_OPTION_ON_WATCH_DOG,
        BOOT_ROM_SUPPORTED,
        CHASSIS_BOOT_UP_STATE,
        CURRENT_TIMEZONE,
        DAYLIGHT_IN_EFFECT,
        DOMAIN_ROLE,
        ENABLE_DAYLIGHT_SAVINGS_TIME,
        FRONT_PANEL_RESET_STATUS,
        INFRARED_SUPPORTED,
        KEYBOARD_PASSWORD_STATUS,
        NETWORK_SERVER_MODE_ENABLED,
        NUMBER_OF_LOGICAL_PROCESSORS,
        NUMBER_OF_PROCESSORS,
        PART_OF_DOMAIN,
        PAUSE_AFTER_RESET,
        POWER_ON_PASSWORD_STATUS,
        POWER_STATE,
        POWER_SUPPLY_STATE,
        RESET_CAPABILITY,
        RESET_COUNT,
        RESET_LIMIT,
        ROLES,
        SYSTEM_STARTUP_DELAY,
        SYSTEM_STARTUP_SETTING,
        SYSTEM_TYPE,
        THERMAL_STATE,
        TOTAL_PHYSICAL_MEMORY,
        WAKEUP_TYPE,
        LAST_CHANGED,
        MODEL,
        _FILEDATE
    from {{ ref('ODS__LANSWEEPER__TBL_COMPUTER_SYSTEM') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data