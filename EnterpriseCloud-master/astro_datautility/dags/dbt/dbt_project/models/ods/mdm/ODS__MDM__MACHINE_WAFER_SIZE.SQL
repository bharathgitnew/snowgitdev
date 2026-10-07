/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\Machine_Wafer_Size__MDM_Machine_Wafer_Size.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\Machine_Wafer_Size.SQL 
-materialized incremental
-alias Machine_Wafer_Size 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 7:25:00 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='Machine_Wafer_Size',
    unique_key = ['Wafer_Size_Source']
) }}


with source_data as 
(
    SELECT 
        jsonfield:"Wafer Size Source"::VARCHAR AS Wafer_Size_Source, 
        jsonfield:"Wafer Size Inch"::VARCHAR AS Wafer_Size_Inch, 
        jsonfield:"Wafer Size MM"::VARCHAR AS Wafer_Size_MM 
        FROM {{ source("MDM", "MACHINE_WAFER_SIZE") }} 
        WHERE _FileDate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "MACHINE_WAFER_SIZE") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.WAFER_SIZE_SOURCE AS Wafer_Size_Source, 
        source_data.WAFER_SIZE_INCH AS Wafer_Size_Inch, 
        source_data.WAFER_SIZE_MM AS Wafer_Size_MM, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(WAFER_SIZE_SOURCE as VARCHAR(16777216)) as WAFER_SIZE_SOURCE,
        cast(WAFER_SIZE_INCH as VARCHAR(16777216)) as WAFER_SIZE_INCH,
        cast(WAFER_SIZE_MM as VARCHAR(16777216)) as WAFER_SIZE_MM,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data