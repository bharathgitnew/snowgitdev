/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-MDM\SalesAccountRegion__SalesAccountRegion.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\mdm\SalesAccountRegion.SQL
-materialized incremental
-alias SalesAccountRegion
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
    alias='SalesAccountRegion',
    unique_key = []
) }}

with source_data as
( 
    SELECT
    SalesAccountRegion.Region,
    SalesAccountRegion.StateOrProvince
    FROM {{ ref('ODS__MDM__SALESACCOUNTREGION') }} SalesAccountRegion

    )
,transform_data as
(
    SELECT
        Region,
        StateOrProvince,
        '{{ invocation_id }}' AS AUDIT_LOG_ID
        FROM source_data
        )
,type_data as 
(
    select
        cast(STATEORPROVINCE as VARCHAR(16777216)) as STATEORPROVINCE,
        cast(REGION as VARCHAR(16777216)) as REGION,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data