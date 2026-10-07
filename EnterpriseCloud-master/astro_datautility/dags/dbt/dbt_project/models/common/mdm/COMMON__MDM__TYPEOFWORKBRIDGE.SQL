/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-MDM\TypeOfWorkBridge__TypeOfWorkBridge.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\mdm\TypeOfWorkBridge.SQL
-materialized incremental
-alias TypeOfWorkBridge
-incremental_strategy insert_overwrite
-envVariable <<ODS>>
-sourceSchema MDM
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/2/2022 4:06:05 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='TypeOfWorkBridge',
    unique_key = []
) }}

with source_data as
(
    SELECT
    TypeOfWorkBridge.Billback_Flag,
    TypeOfWorkBridge.FS_Product_Flag,
    TypeOfWorkBridge.Facotry_Or_TEL,
    TypeOfWorkBridge.Product_Type,
    TypeOfWorkBridge.ToW_FS,
    TypeOfWorkBridge.Type_Of_Work_With_Eval
    FROM {{ ref('ODS__MDM__TYPEOFWORKBRIDGE') }} TypeOfWorkBridge
    )
,transform_data as
(
    SELECT
        Billback_Flag,
        FS_Product_Flag,
        Facotry_Or_TEL,
        Product_Type,
        ToW_FS,
        Type_Of_Work_With_Eval
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        FROM source_data
        )
,type_data as 
(
    select
        cast(TYPE_OF_WORK_WITH_EVAL as VARCHAR(16777216)) as TYPE_OF_WORK_WITH_EVAL,
        cast(FS_PRODUCT_FLAG as VARCHAR(16777216)) as FS_PRODUCT_FLAG,
        cast(BILLBACK_FLAG as VARCHAR(16777216)) as BILLBACK_FLAG,
        cast(PRODUCT_TYPE as VARCHAR(16777216)) as PRODUCT_TYPE,
        cast(FACOTRY_OR_TEL as VARCHAR(16777216)) as FACOTRY_OR_TEL,
        cast(TOW_FS as NUMBER(38,0)) as TOW_FS,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data