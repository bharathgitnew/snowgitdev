/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\Kronos_Shift_Table__MDM_Kronos_Shift_Table.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\Kronos_Shift_Table.SQL 
-materialized incremental
-alias Kronos_Shift_Table 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 7:25:00 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='MDM_KRONOS_SHIFT_TABLE',
    unique_key = ['Work_Rule_Name']
) }}


with source_data as 
(
    SELECT 
        jsonfield:"Work Rule Name"::VARCHAR AS Work_Rule_Name, 
        jsonfield:"Shift Indicated"::VARCHAR AS Shift_Indicated, 
        jsonfield:"Shift Type"::VARCHAR AS Shift_Type 
        FROM {{ source("MDM", "KRONOS_SHIFT_TABLE") }} 
        )
,transform_data as
(
    SELECT 
        source_data.WORK_RULE_NAME AS Work_Rule_Name, 
        source_data.SHIFT_INDICATED AS Shift_Indicated, 
        source_data.SHIFT_TYPE AS Shift_Type, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(WORK_RULE_NAME as VARCHAR(16777216)) as WORK_RULE_NAME,
        cast(SHIFT_INDICATED as VARCHAR(16777216)) as SHIFT_INDICATED,
        cast(SHIFT_TYPE as VARCHAR(16777216)) as SHIFT_TYPE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data

