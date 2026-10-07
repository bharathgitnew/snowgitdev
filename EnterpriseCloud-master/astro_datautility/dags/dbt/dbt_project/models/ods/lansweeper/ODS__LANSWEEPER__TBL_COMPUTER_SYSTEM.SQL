/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Lansweeper\TBL_COMPUTER_SYSTEM__Lansweeper_tblComputersystem.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\lansweeper\TBL_COMPUTER_SYSTEM.SQL 
-materialized incremental
-alias TBL_COMPUTER_SYSTEM 
-incremental_strategy insert_overwrite
-envVariable <<LZ>> 
-sourceSchema LANSWEEPER
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/12/2022 9:15:49 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='TBL_COMPUTER_SYSTEM',
    unique_key = []
) }}


with source_data as 
(
    SELECT 
        _FILENAME 
        ,_FILEDATE 
        ,JSONFIELD:"ComputersystemID"::NUMBER AS Computer_system_ID 
        ,JSONFIELD:"AssetID"::NUMBER AS Asset_ID 
        ,JSONFIELD:"AdminPasswordStatus"::NUMBER AS Admin_Password_Status 
        ,JSONFIELD:"AutomaticResetBootOption"::NUMBER AS Automatic_Reset_Boot_Option 
        ,JSONFIELD:"AutomaticResetCapability"::NUMBER AS Automatic_Reset_Capability 
        ,JSONFIELD:"BootOptionOnLimit"::NUMBER AS Boot_Option_On_Limit 
        ,JSONFIELD:"BootoptionOnWatchDog"::NUMBER AS Boot_option_On_Watch_Dog 
        ,JSONFIELD:"BootRomSupported"::NUMBER AS Boot_Rom_Supported 
        ,JSONFIELD:"ChassisBootupState"::NUMBER AS Chassis_Boot_up_State 
        ,JSONFIELD:"CurrentTimeZone"::NUMBER AS Current_TimeZone 
        ,JSONFIELD:"DaylightInEffect"::NUMBER AS Daylight_In_Effect 
        ,JSONFIELD:"Domainrole"::NUMBER AS Domain_role 
        ,JSONFIELD:"EnableDaylightSavingsTime"::NUMBER AS Enable_Daylight_Savings_Time 
        ,JSONFIELD:"FrontPanelResetStatus"::NUMBER AS Front_Panel_Reset_Status 
        ,JSONFIELD:"Infraredsupported"::NUMBER AS Infrared_supported 
        ,JSONFIELD:"KeyboardPasswordStatus"::NUMBER AS Keyboard_Password_Status 
        ,JSONFIELD:"NetworkServerModeEnabled"::NUMBER AS Network_Server_Mode_Enabled 
        ,JSONFIELD:"NumberOfLogicalProcessors"::NUMBER AS Number_Of_Logical_Processors 
        ,JSONFIELD:"NumberOfProcessors"::NUMBER AS Number_Of_Processors 
        ,JSONFIELD:"PartOfDomain"::NUMBER AS Part_Of_Domain 
        ,JSONFIELD:"PauseAfterReset"::NUMBER AS Pause_After_Reset 
        ,JSONFIELD:"PowerOnPasswordStatus"::NUMBER AS Power_On_Password_Status 
        ,JSONFIELD:"Powerstate"::NUMBER AS Power_state 
        ,JSONFIELD:"PowerSupplyState"::NUMBER AS Power_Supply_State 
        ,JSONFIELD:"ResetCapability"::NUMBER AS Reset_Capability 
        ,JSONFIELD:"ResetCount"::NUMBER AS Reset_Count 
        ,JSONFIELD:"Resetlimit"::NUMBER AS Reset_limit 
        ,JSONFIELD:"Roles"::STRING AS Roles 
        ,JSONFIELD:"SystemStartupDelay"::NUMBER AS System_Startup_Delay 
        ,JSONFIELD:"SystemStartupSetting"::NUMBER AS System_Startup_Setting 
        ,JSONFIELD:"SystemType"::STRING AS System_Type 
        ,JSONFIELD:"ThermalState"::NUMBER AS Thermal_State 
        ,JSONFIELD:"TotalPhysicalMemory"::NUMBER AS Total_Physical_Memory 
        ,JSONFIELD:"Wakeuptype"::NUMBER AS Wakeup_type 
        ,REGEXP_REPLACE(JSONFIELD:"Lastchanged", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Last_changed 
        ,JSONFIELD:"Model"::STRING AS Model 
        FROM {{ source("LANSWEEPER", "TBLCOMPUTERSYSTEM") }} 
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("LANSWEEPER", "TBLCOMPUTERSYSTEM") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.ADMIN_PASSWORD_STATUS, 
        source_data.ASSET_ID, 
        source_data.AUTOMATIC_RESET_BOOT_OPTION, 
        source_data.AUTOMATIC_RESET_CAPABILITY, 
        source_data.BOOT_OPTION_ON_LIMIT, 
        source_data.BOOT_OPTION_ON_WATCH_DOG, 
        source_data.BOOT_ROM_SUPPORTED, 
        source_data.CHASSIS_BOOT_UP_STATE, 
        source_data.COMPUTER_SYSTEM_ID, 
        source_data.CURRENT_TIMEZONE, 
        source_data.DAYLIGHT_IN_EFFECT, 
        source_data.DOMAIN_ROLE, 
        source_data.ENABLE_DAYLIGHT_SAVINGS_TIME, 
        source_data.FRONT_PANEL_RESET_STATUS, 
        source_data.INFRARED_SUPPORTED, 
        source_data.KEYBOARD_PASSWORD_STATUS, 
        source_data.LAST_CHANGED, 
        source_data.MODEL, 
        source_data.NETWORK_SERVER_MODE_ENABLED, 
        source_data.NUMBER_OF_LOGICAL_PROCESSORS, 
        source_data.NUMBER_OF_PROCESSORS, 
        source_data.PART_OF_DOMAIN, 
        source_data.PAUSE_AFTER_RESET, 
        source_data.POWER_ON_PASSWORD_STATUS, 
        source_data.POWER_STATE, 
        source_data.POWER_SUPPLY_STATE, 
        source_data.RESET_CAPABILITY, 
        source_data.RESET_COUNT, 
        source_data.RESET_LIMIT, 
        source_data.ROLES, 
        source_data.SYSTEM_STARTUP_DELAY, 
        source_data.SYSTEM_STARTUP_SETTING, 
        source_data.SYSTEM_TYPE, 
        source_data.THERMAL_STATE, 
        source_data.TOTAL_PHYSICAL_MEMORY, 
        source_data.WAKEUP_TYPE, 
        source_data._FILEDATE 
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID 
        FROM source_data
        )
,type_data as 
(
    select
        cast(COMPUTER_SYSTEM_ID as NUMBER(38,0)) as COMPUTER_SYSTEM_ID,
        cast(ASSET_ID as NUMBER(38,0)) as ASSET_ID,
        cast(ADMIN_PASSWORD_STATUS as NUMBER(38,0)) as ADMIN_PASSWORD_STATUS,
        cast(AUTOMATIC_RESET_BOOT_OPTION as NUMBER(38,0)) as AUTOMATIC_RESET_BOOT_OPTION,
        cast(AUTOMATIC_RESET_CAPABILITY as NUMBER(38,0)) as AUTOMATIC_RESET_CAPABILITY,
        cast(BOOT_OPTION_ON_LIMIT as NUMBER(38,0)) as BOOT_OPTION_ON_LIMIT,
        cast(BOOT_OPTION_ON_WATCH_DOG as NUMBER(38,0)) as BOOT_OPTION_ON_WATCH_DOG,
        cast(BOOT_ROM_SUPPORTED as NUMBER(38,0)) as BOOT_ROM_SUPPORTED,
        cast(CHASSIS_BOOT_UP_STATE as NUMBER(38,0)) as CHASSIS_BOOT_UP_STATE,
        cast(CURRENT_TIMEZONE as NUMBER(38,0)) as CURRENT_TIMEZONE,
        cast(DAYLIGHT_IN_EFFECT as NUMBER(38,0)) as DAYLIGHT_IN_EFFECT,
        cast(DOMAIN_ROLE as NUMBER(38,0)) as DOMAIN_ROLE,
        cast(ENABLE_DAYLIGHT_SAVINGS_TIME as NUMBER(38,0)) as ENABLE_DAYLIGHT_SAVINGS_TIME,
        cast(FRONT_PANEL_RESET_STATUS as NUMBER(38,0)) as FRONT_PANEL_RESET_STATUS,
        cast(INFRARED_SUPPORTED as NUMBER(38,0)) as INFRARED_SUPPORTED,
        cast(KEYBOARD_PASSWORD_STATUS as NUMBER(38,0)) as KEYBOARD_PASSWORD_STATUS,
        cast(NETWORK_SERVER_MODE_ENABLED as NUMBER(38,0)) as NETWORK_SERVER_MODE_ENABLED,
        cast(NUMBER_OF_LOGICAL_PROCESSORS as NUMBER(38,0)) as NUMBER_OF_LOGICAL_PROCESSORS,
        cast(NUMBER_OF_PROCESSORS as NUMBER(38,0)) as NUMBER_OF_PROCESSORS,
        cast(PART_OF_DOMAIN as NUMBER(38,0)) as PART_OF_DOMAIN,
        cast(PAUSE_AFTER_RESET as NUMBER(38,0)) as PAUSE_AFTER_RESET,
        cast(POWER_ON_PASSWORD_STATUS as NUMBER(38,0)) as POWER_ON_PASSWORD_STATUS,
        cast(POWER_STATE as NUMBER(38,0)) as POWER_STATE,
        cast(POWER_SUPPLY_STATE as NUMBER(38,0)) as POWER_SUPPLY_STATE,
        cast(RESET_CAPABILITY as NUMBER(38,0)) as RESET_CAPABILITY,
        cast(RESET_COUNT as NUMBER(38,0)) as RESET_COUNT,
        cast(RESET_LIMIT as NUMBER(38,0)) as RESET_LIMIT,
        cast(ROLES as VARCHAR(16777216)) as ROLES,
        cast(SYSTEM_STARTUP_DELAY as NUMBER(38,0)) as SYSTEM_STARTUP_DELAY,
        cast(SYSTEM_STARTUP_SETTING as NUMBER(38,0)) as SYSTEM_STARTUP_SETTING,
        cast(SYSTEM_TYPE as VARCHAR(16777216)) as SYSTEM_TYPE,
        cast(THERMAL_STATE as NUMBER(38,0)) as THERMAL_STATE,
        cast(TOTAL_PHYSICAL_MEMORY as NUMBER(38,0)) as TOTAL_PHYSICAL_MEMORY,
        cast(WAKEUP_TYPE as NUMBER(38,0)) as WAKEUP_TYPE,
        cast(LAST_CHANGED as TIMESTAMP_NTZ(9)) as LAST_CHANGED,
        cast(MODEL as VARCHAR(16777216)) as MODEL,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data