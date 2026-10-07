/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\Machine_Status_Mapping__MDM_Machine_Status_Mapping.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\Machine_Status_Mapping.SQL 
-materialized incremental
-alias Machine_Status_Mapping 
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
    alias='MDM_MACHINE_STATUS_MAPPING',
    unique_key = ['Status_Key']
) }}


with source_data as 
(
    SELECT 
        jsonfield:"Status Key"::NUMBER AS Status_Key, 
        jsonfield:"Machine Status"::VARCHAR AS Machine_Status, 
        jsonfield:"Expired Flag"::VARCHAR AS Expired_Flag, 
        jsonfield:"Eval Flag"::VARCHAR AS Eval_Flag, 
        jsonfield:"Install Base Status"::VARCHAR AS Install_Base_Status, 
        jsonfield:"Status Sort"::NUMBER AS Status_Sort 
        FROM {{ source("MDM", "MACHINE_STATUS_MAPPING") }} 
        WHERE _FileDate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "MACHINE_STATUS_MAPPING") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.STATUS_KEY AS Status_Key, 
        source_data.MACHINE_STATUS AS Machine_Status, 
        source_data.EXPIRED_FLAG AS Expired_Flag, 
        source_data.EVAL_FLAG AS Eval_Flag, 
        source_data.INSTALL_BASE_STATUS AS Install_Base_Status, 
        source_data.STATUS_SORT AS Status_Sort, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(STATUS_KEY as NUMBER(38,0)) as STATUS_KEY,
        cast(MACHINE_STATUS as VARCHAR(16777216)) as MACHINE_STATUS,
        cast(EXPIRED_FLAG as VARCHAR(16777216)) as EXPIRED_FLAG,
        cast(EVAL_FLAG as VARCHAR(16777216)) as EVAL_FLAG,
        cast(INSTALL_BASE_STATUS as VARCHAR(16777216)) as INSTALL_BASE_STATUS,
        cast(STATUS_SORT as NUMBER(38,0)) as STATUS_SORT,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data

