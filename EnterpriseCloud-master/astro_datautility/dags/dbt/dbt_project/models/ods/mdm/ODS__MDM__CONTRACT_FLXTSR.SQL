/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\Contract_FLXTSR__MDM_Contract_FLXTSR.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\Contract_FLXTSR.SQL 
-materialized incremental
-alias Contract_FLXTSR 
-incremental_strategy insert_overwrite
-envVariable <<LZ>> 
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 7:24:59 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='Contract_FLXTSR',
    unique_key = []
) }}


with source_data as 
(
    SELECT  
        jsonfield:"RevRec Month"::VARCHAR AS RevRec_Month, 
        jsonfield:"RevRec Date"::VARCHAR AS RevRec_Date, 
        jsonfield:"Contract #"::VARCHAR AS Contract_Number, 
        jsonfield:"SO #"::VARCHAR AS SO_Number, 
        jsonfield:"Actual TSR Hours"::NUMBER AS Actual_TSR_Hours, 
        jsonfield:"Actual TSR Amount"::NUMBER AS Actual_TSR_Amount, 
        jsonfield:"Finance TSR Hours"::NUMBER AS Finance_TSR_Hours, 
        jsonfield:"Finance Revenue Amount"::NUMBER AS Finance_Revenue_Amount, 
        jsonfield:"Customer"::VARCHAR AS Customer, 
        jsonfield:"BU"::VARCHAR AS BU, 
        jsonfield:"Office"::VARCHAR AS Office, 
        jsonfield:"Customer Code"::VARCHAR AS Customer_Code, 
        jsonfield:"Office Code"::VARCHAR AS Office_Code, 
        jsonfield:"BU Code"::VARCHAR AS BU_Code, 
        jsonfield:"Product Type Code"::VARCHAR AS Product_Type_Code, 
        jsonfield:"Serial Number"::VARCHAR AS Serial_Number, 
        jsonfield:"Sold To Code"::VARCHAR AS Sold_To_Code, 
        jsonfield:"TSR Consumed Remaining Hours"::VARCHAR AS TSR_Consumed_Remaining_Hours, 
        jsonfield:"Comments"::VARCHAR AS Comments, 
        jsonfield:"Modified"::VARCHAR AS Modified, 
        jsonfield:"Modified By"::VARCHAR AS Modified_By 
        FROM {{ source("MDM", "CONTRACT_FLXTSR") }} 
        )
,transform_data as
(
    SELECT 
        source_data.ACTUAL_TSR_AMOUNT, 
        source_data.ACTUAL_TSR_HOURS, 
        source_data.BU, 
        source_data.BU_CODE, 
        source_data.COMMENTS, 
        source_data.CONTRACT_NUMBER, 
        source_data.CUSTOMER, 
        source_data.CUSTOMER_CODE, 
        source_data.FINANCE_REVENUE_AMOUNT, 
        source_data.FINANCE_TSR_HOURS, 
        TO_TIMESTAMP_NTZ(REPLACE(REPLACE(source_data.MODIFIED,'/Date(',''),')/','')) AS MODIFIED, 
        source_data.MODIFIED_BY, 
        source_data.OFFICE, 
        source_data.OFFICE_CODE, 
        source_data.PRODUCT_TYPE_CODE, 
        TO_TIMESTAMP_NTZ(REPLACE(REPLACE(source_data.REVREC_DATE,'/Date(',''),')/','')) AS REVREC_DATE, 
        source_data.REVREC_MONTH, 
        source_data.SO_NUMBER, 
        source_data.SERIAL_NUMBER, 
        source_data.SOLD_TO_CODE, 
        source_data.TSR_CONSUMED_REMAINING_HOURS 
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID 
        FROM source_data
        )
,type_data as 
(
    select
        cast(REVREC_MONTH as VARCHAR(16777216)) as REVREC_MONTH,
        cast(REVREC_DATE as TIMESTAMP_NTZ(9)) as REVREC_DATE,
        cast(CONTRACT_NUMBER as VARCHAR(16777216)) as CONTRACT_NUMBER,
        cast(SO_NUMBER as VARCHAR(16777216)) as SO_NUMBER,
        cast(ACTUAL_TSR_HOURS as NUMBER(38,10)) as ACTUAL_TSR_HOURS,
        cast(ACTUAL_TSR_AMOUNT as NUMBER(38,10)) as ACTUAL_TSR_AMOUNT,
        cast(FINANCE_TSR_HOURS as NUMBER(38,10)) as FINANCE_TSR_HOURS,
        cast(FINANCE_REVENUE_AMOUNT as NUMBER(38,10)) as FINANCE_REVENUE_AMOUNT,
        cast(CUSTOMER as VARCHAR(16777216)) as CUSTOMER,
        cast(BU as VARCHAR(16777216)) as BU,
        cast(OFFICE as VARCHAR(16777216)) as OFFICE,
        cast(CUSTOMER_CODE as VARCHAR(16777216)) as CUSTOMER_CODE,
        cast(OFFICE_CODE as VARCHAR(16777216)) as OFFICE_CODE,
        cast(BU_CODE as VARCHAR(16777216)) as BU_CODE,
        cast(PRODUCT_TYPE_CODE as VARCHAR(16777216)) as PRODUCT_TYPE_CODE,
        cast(SERIAL_NUMBER as VARCHAR(16777216)) as SERIAL_NUMBER,
        cast(SOLD_TO_CODE as VARCHAR(16777216)) as SOLD_TO_CODE,
        cast(TSR_CONSUMED_REMAINING_HOURS as VARCHAR(16777216)) as TSR_CONSUMED_REMAINING_HOURS,
        cast(COMMENTS as VARCHAR(16777216)) as COMMENTS,
        cast(MODIFIED as TIMESTAMP_NTZ(9)) as MODIFIED,
        cast(MODIFIED_BY as VARCHAR(16777216)) as MODIFIED_BY,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data