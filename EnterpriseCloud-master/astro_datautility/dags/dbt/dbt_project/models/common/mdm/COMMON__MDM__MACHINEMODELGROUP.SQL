/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-MDM\Machine_Model_Group__MachineModelGroup.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\mdm\MachineModelGroup.SQL
-materialized incremental
-alias MachineModelGroup
-incremental_strategy merge
-envVariable <<ODS>>
-sourceSchema MDM
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/2/2022 4:06:04 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='MachineModelGroup',
    unique_key = []
) }}

with source_data as
(
  SELECT
    Machine_Model_Group.BU AS BU,
    Machine_Model_Group.SWLH_Model AS SWLH_Model,
    Machine_Model_Group.Model_Category AS Model_Category,
    Machine_Model_Group.Model_Sub_Category AS Model_Sub_Category
    FROM {{ ref('ODS__MDM__MACHINE_MODEL_GROUP') }} Machine_Model_Group
    )
,transform_data as
(
    SELECT
        BU,
        SWLH_Model,
        Model_Category,
        Model_Sub_Category
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        -- ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(BU as VARCHAR(16777216)) as BU,
        cast(SWLH_MODEL as VARCHAR(16777216)) as SWLH_MODEL,
        cast(MODEL_CATEGORY as VARCHAR(16777216)) as MODEL_CATEGORY,
        cast(MODEL_SUB_CATEGORY as VARCHAR(16777216)) as MODEL_SUB_CATEGORY,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data