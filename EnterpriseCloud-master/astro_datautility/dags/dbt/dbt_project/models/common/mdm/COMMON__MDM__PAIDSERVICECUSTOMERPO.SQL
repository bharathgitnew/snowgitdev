/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-MDM\Paid_Service_Customer_PO__PaidCustomerPO.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\mdm\PaidServiceCustomerPO.SQL
-materialized incremental
-alias PaidServiceCustomerPO
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
    alias='PaidServiceCustomerPO',
    unique_key = ['PO_Number']
) }}

with source_data as
( SELECT
    Paid_Service_Customer_PO.PO_Number_2 AS PO_Number_2,
    Paid_Service_Customer_PO.PO_Number_2_SO_Number AS PO_Number_2_SO_Number,
    Paid_Service_Customer_PO.PO_Number AS PO_Number,
    Paid_Service_Customer_PO.Customer_Group AS Customer_Group,
    Paid_Service_Customer_PO.Fab_2_Parent_Customer_Name AS Fab_2_Parent_Customer_Name,
    Paid_Service_Customer_PO.Business_Issuing_PO AS Business_Issuing_PO,
    Paid_Service_Customer_PO.Work_Start AS Work_Start,
    Paid_Service_Customer_PO.Planned_End_Date AS Planned_End_Date,
    Paid_Service_Customer_PO.BU AS BU,
    Paid_Service_Customer_PO.Fab AS Fab,
    Paid_Service_Customer_PO.Config AS Config,
    Paid_Service_Customer_PO.Site_Supervisor AS Site_Supervisor,
    Paid_Service_Customer_PO.PO_Amount AS PO_Amount,
    Paid_Service_Customer_PO.PO_Amt_Calculated AS PO_Amt_Calculated,
    Paid_Service_Customer_PO.Received_Date AS Received_Date,
    Paid_Service_Customer_PO.PO_Type AS PO_Type,
    Paid_Service_Customer_PO.PO_Status AS PO_Status,
    Paid_Service_Customer_PO.Quote AS Quote,
    Paid_Service_Customer_PO.PO_Description AS PO_Description,
    Paid_Service_Customer_PO.Correct_Payment_Terms AS Correct_Payment_Terms,
    Paid_Service_Customer_PO.Issued_To_TEA AS Issued_To_TEA,
    Paid_Service_Customer_PO.SIG_Comments AS SIG_Comments,
    Paid_Service_Customer_PO.Table_Refresh_Date AS Table_Refresh_Date
    FROM {{ ref('ODS__MDM__PAID_SERVICE_CUSTOMER_PO') }} Paid_Service_Customer_PO
    )
,transform_data as
(
    SELECT
        PO_Number_2,
        PO_Number_2_SO_Number,
        PO_Number,
        Customer_Group,
        Fab_2_Parent_Customer_Name,
        Business_Issuing_PO,
        Work_Start,
        Planned_End_Date,
        BU,
        Fab,
        Config,
        Site_Supervisor,
        PO_Amount,
        PO_Amt_Calculated,
        Received_Date,
        PO_Type,
        PO_Status,
        Quote,
        PO_Description,
        Correct_Payment_Terms,
        Issued_To_TEA,
        SIG_Comments,
        Table_Refresh_Date
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as 
(
    select
        cast(PO_NUMBER_2 as VARCHAR(16777216)) as PO_NUMBER_2,
        cast(PO_NUMBER_2_SO_NUMBER as VARCHAR(16777216)) as PO_NUMBER_2_SO_NUMBER,
        cast(PO_NUMBER as VARCHAR(16777216)) as PO_NUMBER,
        cast(CUSTOMER_GROUP as VARCHAR(16777216)) as CUSTOMER_GROUP,
        cast(FAB_2_PARENT_CUSTOMER_NAME as VARCHAR(16777216)) as FAB_2_PARENT_CUSTOMER_NAME,
        cast(BUSINESS_ISSUING_PO as VARCHAR(16777216)) as BUSINESS_ISSUING_PO,
        cast(WORK_START as TIMESTAMP_NTZ(9)) as WORK_START,
        cast(PLANNED_END_DATE as TIMESTAMP_NTZ(9)) as PLANNED_END_DATE,
        cast(BU as VARCHAR(16777216)) as BU,
        cast(FAB as VARCHAR(16777216)) as FAB,
        cast(CONFIG as VARCHAR(16777216)) as CONFIG,
        cast(SITE_SUPERVISOR as VARCHAR(16777216)) as SITE_SUPERVISOR,
        cast(PO_AMOUNT as VARCHAR(16777216)) as PO_AMOUNT,
        cast(PO_AMT_CALCULATED as NUMBER(38,10)) as PO_AMT_CALCULATED,
        cast(RECEIVED_DATE as TIMESTAMP_NTZ(9)) as RECEIVED_DATE,
        cast(PO_TYPE as VARCHAR(16777216)) as PO_TYPE,
        cast(PO_STATUS as VARCHAR(16777216)) as PO_STATUS,
        cast(QUOTE as VARCHAR(16777216)) as QUOTE,
        cast(PO_DESCRIPTION as VARCHAR(16777216)) as PO_DESCRIPTION,
        cast(CORRECT_PAYMENT_TERMS as VARCHAR(16777216)) as CORRECT_PAYMENT_TERMS,
        cast(ISSUED_TO_TEA as VARCHAR(16777216)) as ISSUED_TO_TEA,
        cast(SIG_COMMENTS as VARCHAR(16777216)) as SIG_COMMENTS,
        cast(TABLE_REFRESH_DATE as TIMESTAMP_NTZ(9)) as TABLE_REFRESH_DATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data