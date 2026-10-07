/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\Contract_FLX_TransitionHRs__MDM_Contract_FLX.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\Contract_FLX_TransitionHRs.SQL 
-materialized incremental
-alias Contract_FLX_TransitionHRs 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 7:24:59 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='Contract_FLX_TransitionHRs',
    unique_key = ['Contract_Number']
) }}


with source_data as 
(
    SELECT 
        jsonfield:"Customer Name"::VARCHAR AS Customer_Name, 
        jsonfield:"Contract Number"::VARCHAR AS Contract_Number, 
        jsonfield:"FY21 Kronos Hours"::NUMBER AS FY21_Kronos_Hours, 
        jsonfield:"Load Date"::VARCHAR AS Load_Date, 
        jsonfield:"Updated FY21 Hours"::NUMBER AS Updated_FY21_Hours, 
        jsonfield:"Updated Comment"::VARCHAR AS Updated_Comment 
        FROM {{ source("MDM", "CONTRACT_FLX_TRANSITIONHRS") }} 
        )
,transform_data as
(
    SELECT 
        source_data.CUSTOMER_NAME AS Customer_Name, 
        source_data.CONTRACT_NUMBER AS Contract_Number, 
        source_data.FY21_KRONOS_HOURS AS FY21_Kronos_Hours, 
        TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.LOAD_DATE , '/Date(' , '' ) , ')/' , '' ) ) AS Load_Date, 
        source_data.UPDATED_FY21_HOURS AS Updated_FY21_Hours, 
        source_data.UPDATED_COMMENT AS Updated_Comment, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
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