/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-MDM\Contract_FLXTSR__ContractFLXTSR.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\mdm\ContractFLXTSR.SQL
-materialized incremental
-alias ContractFLXTSR
-incremental_strategy insert_overwrite
-envVariable <<ODS>>
-sourceSchema MDM
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/2/2022 4:06:04 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='ContractFLXTSR',
    unique_key = []
) }}

with source_data as
(  
    SELECT
    Contract_FLXTSR.Actual_TSR_Amount,
    Contract_FLXTSR.Actual_TSR_Hours,
    Contract_FLXTSR.BU,
    Contract_FLXTSR.BU_Code,
    Contract_FLXTSR.Comments,
    Contract_FLXTSR.Contract_Number,
    Contract_FLXTSR.Customer,
    Contract_FLXTSR.Customer_Code,
    Contract_FLXTSR.Finance_Revenue_Amount,
    Contract_FLXTSR.Finance_TSR_Hours,
    Contract_FLXTSR.Modified,
    Contract_FLXTSR.Modified_By,
    Contract_FLXTSR.Office,
    Contract_FLXTSR.Office_Code,
    Contract_FLXTSR.Product_Type_Code,
    Contract_FLXTSR.RevRec_Date,
    Contract_FLXTSR.RevRec_Month,
    Contract_FLXTSR.SO_Number,
    Contract_FLXTSR.Serial_Number,
    Contract_FLXTSR.Sold_To_Code,
    Contract_FLXTSR.TSR_Consumed_Remaining_Hours
    FROM {{ ref('ODS__MDM__CONTRACT_FLXTSR') }} Contract_FLXTSR
    )
    
,transform_data as
(
    SELECT
        Actual_TSR_Amount,
        Actual_TSR_Hours,
        BU,
        BU_Code,
        Comments,
        Contract_Number,
        Customer,
        Customer_Code,
        Finance_Revenue_Amount,
        Finance_TSR_Hours,
        Modified,
        Modified_By,
        Office,
        Office_Code,
        Product_Type_Code,
        RevRec_Date,
        RevRec_Month,
        SO_Number,
        Serial_Number,
        Sold_To_Code,
        TSR_Consumed_Remaining_Hours,
        '{{ invocation_id }}' AS AUDIT_LOG_ID
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