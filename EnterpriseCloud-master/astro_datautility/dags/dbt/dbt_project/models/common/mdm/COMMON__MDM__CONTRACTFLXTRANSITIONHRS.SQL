/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-MDM\Contract_FLX_TransitionHRs_ContractFlx.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\mdm\ContractFLXTransitionHRS.SQL
-materialized incremental
-alias ContractFLXTransitionHRS
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
    alias='ContractFLXTransitionHRS',
    unique_key = ['Contract_Number']
) }}

with source_data as
(
    SELECT
    Contract_FLX_TransitionHrs.Customer_Name AS Customer_Name,
    Contract_FLX_TransitionHrs.Contract_Number AS Contract_Number,
    Contract_FLX_TransitionHrs.FY21_Kronos_Hours AS FY21_Kronos_Hours,
    Contract_FLX_TransitionHrs.Load_Date AS Load_Date,
    Contract_FLX_TransitionHrs.Updated_FY21_Hours AS Updated_FY21_Hours,
    Contract_FLX_TransitionHrs.Updated_Comment AS Updated_Comment
    FROM {{ ref('ODS__MDM__CONTRACT_FLX_TRANSITIONHRS') }} Contract_FLX_TransitionHrs
    )
,transform_data as
(
    SELECT
        Customer_Name,
        Contract_Number,
        FY21_Kronos_Hours,
        Load_Date,
        Updated_FY21_Hours,
        Updated_Comment,
        '{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as 
(
    select
        cast(CUSTOMER_NAME as VARCHAR(16777216)) as CUSTOMER_NAME,
        cast(CONTRACT_NUMBER as VARCHAR(16777216)) as CONTRACT_NUMBER,
        cast(FY21_KRONOS_HOURS as NUMBER(38,10)) as FY21_KRONOS_HOURS,
        cast(LOAD_DATE as TIMESTAMP_NTZ(9)) as LOAD_DATE,
        cast(UPDATED_FY21_HOURS as NUMBER(38,10)) as UPDATED_FY21_HOURS,
        cast(UPDATED_COMMENT as VARCHAR(16777216)) as UPDATED_COMMENT,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data