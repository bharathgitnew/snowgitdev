/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-MDM\PDS_Quote_Request__PaidServiceQuote.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\mdm\PaidServiceQuote.SQL
-materialized incremental
-alias PaidServiceQuote
-incremental_strategy merge
-envVariable <<ODS>>
-sourceSchema MDM
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/2/2022 4:06:05 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='PaidServiceQuote',
    unique_key = []
) }}

with source_data as
(   SELECT
    PDS_Quote_Request.Quote_Number AS Quote_Number,
    PDS_Quote_Request.Quote_Status AS Quote_Status,
    PDS_Quote_Request.Quote_Date AS Quote_Date,
    PDS_Quote_Request.Config AS Config,
    PDS_Quote_Request.Config_old AS Config_old,
    PDS_Quote_Request.Product_Line AS Product_Line,
    PDS_Quote_Request.Fab_Location AS Fab_Location,
    PDS_Quote_Request.PO_Number AS PO_Number,
    PDS_Quote_Request.Estimated_Total AS Estimated_Total,
    PDS_Quote_Request.Calc_Estimated_Total AS Calc_Estimated_Total,
    PDS_Quote_Request.Requestor_Name AS Requestor_Name,
    PDS_Quote_Request.Customer AS Customer,
    PDS_Quote_Request.Start_Time AS Start_Time,
    PDS_Quote_Request.End_Time AS End_Time,
    PDS_Quote_Request.Work_Description AS Work_Description,
    PDS_Quote_Request.Decommission AS Decommission,
    PDS_Quote_Request.Status AS Status,
    PDS_Quote_Request.Customer_Group AS Customer_Group,
    PDS_Quote_Request.Serial_Number AS Serial_Number,
    PDS_Quote_Request.Tool_ID AS Tool_ID,
    PDS_Quote_Request.Probability AS Probability,
    PDS_Quote_Request.Table_Refresh_Date AS Table_Refresh_Date
    FROM {{ ref('ODS__MDM__PDS_QUOTE_REQUEST') }} PDS_Quote_Request
    )
,transform_data as
(
    SELECT
        Quote_Number,
        Quote_Status,
        Quote_Date,
        Config,
        Config_old,
        Product_Line,
        Fab_Location,
        PO_Number,
        Estimated_Total,
        Calc_Estimated_Total,
        Requestor_Name,
        Customer,
        Start_Time,
        End_Time,
        Work_Description,
        Decommission,
        Status,
        Customer_Group,
        Serial_Number,
        Tool_ID,
        Probability,
        Table_Refresh_Date,
        '{{ invocation_id }}' AS AUDIT_LOG_ID
        -- ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(QUOTE_NUMBER as VARCHAR(16777216)) as QUOTE_NUMBER,
        cast(QUOTE_STATUS as VARCHAR(16777216)) as QUOTE_STATUS,
        cast(QUOTE_DATE as VARCHAR(16777216)) as QUOTE_DATE,
        cast(CONFIG as VARCHAR(16777216)) as CONFIG,
        cast(CONFIG_OLD as VARCHAR(16777216)) as CONFIG_OLD,
        cast(PRODUCT_LINE as VARCHAR(16777216)) as PRODUCT_LINE,
        cast(FAB_LOCATION as VARCHAR(16777216)) as FAB_LOCATION,
        cast(PO_NUMBER as VARCHAR(16777216)) as PO_NUMBER,
        cast(ESTIMATED_TOTAL as NUMBER(38,10)) as ESTIMATED_TOTAL,
        cast(CALC_ESTIMATED_TOTAL as NUMBER(38,10)) as CALC_ESTIMATED_TOTAL,
        cast(REQUESTOR_NAME as VARCHAR(16777216)) as REQUESTOR_NAME,
        cast(CUSTOMER as VARCHAR(16777216)) as CUSTOMER,
        cast(START_TIME as TIMESTAMP_NTZ(9)) as START_TIME,
        cast(END_TIME as TIMESTAMP_NTZ(9)) as END_TIME,
        cast(WORK_DESCRIPTION as VARCHAR(16777216)) as WORK_DESCRIPTION,
        cast(DECOMMISSION as VARCHAR(16777216)) as DECOMMISSION,
        cast(STATUS as VARCHAR(16777216)) as STATUS,
        cast(CUSTOMER_GROUP as VARCHAR(16777216)) as CUSTOMER_GROUP,
        cast(SERIAL_NUMBER as VARCHAR(16777216)) as SERIAL_NUMBER,
        cast(TOOL_ID as VARCHAR(16777216)) as TOOL_ID,
        cast(PROBABILITY as VARCHAR(16777216)) as PROBABILITY,
        cast(TABLE_REFRESH_DATE as TIMESTAMP_NTZ(9)) as TABLE_REFRESH_DATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data