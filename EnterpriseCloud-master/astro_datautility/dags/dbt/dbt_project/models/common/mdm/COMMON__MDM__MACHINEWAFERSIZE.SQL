/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-MDM\Machine_Wafer_Size__MachineWaferSize.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\mdm\MachineWaferSize.SQL
-materialized incremental
-alias MachineWaferSize
-incremental_strategy merge
-envVariable <<ODS>>
-sourceSchema MDM
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/2/2022 4:06:04 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='MachineWaferSize',
    unique_key = ['Wafer_Size_Source']
) }}

with source_data as
( 
    SELECT
    Machine_Wafer_Size.Wafer_Size_Source AS Wafer_Size_Source,
    Machine_Wafer_Size.Wafer_Size_Inch AS Wafer_Size_Inch,
    Machine_Wafer_Size.Wafer_Size_MM AS Wafer_Size_MM
    FROM {{ ref('ODS__MDM__MACHINE_WAFER_SIZE') }} Machine_Wafer_Size
    )
,transform_data as
(
    SELECT
        Wafer_Size_Source,
        Wafer_Size_Inch,
        Wafer_Size_MM
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
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