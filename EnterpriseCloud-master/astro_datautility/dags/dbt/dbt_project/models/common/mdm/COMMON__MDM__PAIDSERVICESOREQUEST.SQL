/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-MDM\Paid_Service_SO_Request__PaidSORequest.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\mdm\PaidServiceSORequest.SQL
-materialized incremental
-alias PaidServiceSORequest
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
    alias='PaidServiceSORequest',
    unique_key = []
) }}

with source_data as
( SELECT
    Paid_Service_SO_Request.SORequest_Date AS SORequest_Date,
    Paid_Service_SO_Request.SO_Number AS SO_Number,
    Paid_Service_SO_Request.Requestor AS Requestor,
    Paid_Service_SO_Request.Customer_Fab_2_Customer_Group AS Customer_Fab_2_Customer_Group,
    Paid_Service_SO_Request.Customer_Fab_2_Office AS Customer_Fab_2_Office,
    Paid_Service_SO_Request.Fab AS Fab,
    Paid_Service_SO_Request.BU AS BU,
    Paid_Service_SO_Request.PONumber AS PONumber,
    Paid_Service_SO_Request.Quote_Number AS Quote_Number,
    Paid_Service_SO_Request.Customer_Fab_2 AS Customer_Fab_2,
    Paid_Service_SO_Request.Est_Hours AS Est_Hours,
    Paid_Service_SO_Request.SOStart AS SOStart,
    Paid_Service_SO_Request.SOEnd AS SOEnd,
    Paid_Service_SO_Request.Business AS Business,
    Paid_Service_SO_Request.Service_Type AS Service_Type,
    Paid_Service_SO_Request.Description AS Description,
    Paid_Service_SO_Request.SN AS SN,
    Paid_Service_SO_Request.Credit_Check AS Credit_Check,
    Paid_Service_SO_Request.Decom AS Decom,
    Paid_Service_SO_Request.Request_Comments AS Request_Comments,
    Paid_Service_SO_Request.SIG_Comments AS SIG_Comments,
    Paid_Service_SO_Request.Updates_From_Field AS Updates_From_Field,
    Paid_Service_SO_Request.SIG_Notes_To_Field AS SIG_Notes_To_Field,
    Paid_Service_SO_Request.Total_TSRAmount_Input AS Total_TSRAmount_Input,
    Paid_Service_SO_Request.Attachment_Added AS Attachment_Added,
    Paid_Service_SO_Request.Invoicing_Status AS Invoicing_Status,
    Paid_Service_SO_Request.TSR_Amt AS TSR_Amt,
    Paid_Service_SO_Request.Config AS Config,
    Paid_Service_SO_Request.Table_Refresh_Date AS Table_Refresh_Date
FROM {{ ref('ODS__MDM__PAID_SERVICE_SO_REQUEST') }} Paid_Service_SO_Request
    )
,transform_data as
(
    SELECT
        SORequest_Date AS SORequest_Date,
        SO_Number AS SO_Number,
        Requestor AS Requestor,
        Customer_Fab_2_Customer_Group AS Customer_Fab_2_Customer_Group,
        Customer_Fab_2_Office AS Customer_Fab_2_Office,
        Fab AS Fab,
        BU AS BU,
        PONumber AS PONumber,
        Quote_Number AS Quote_Number,
        Customer_Fab_2 AS Customer_Fab_2,
        Est_Hours AS Est_Hours,
        SOStart AS SOStart,
        SOEnd AS SOEnd,
        Business AS Business,
        Service_Type AS Service_Type,
        Description AS Description,
        SN AS SN,
        Credit_Check AS Credit_Check,
        Decom AS Decom,
        Request_Comments AS Request_Comments,
        SIG_Comments AS SIG_Comments,
        Updates_From_Field AS Updates_From_Field,
        SIG_Notes_To_Field AS SIG_Notes_To_Field,
        Total_TSRAmount_Input AS Total_TSRAmount_Input,
        Attachment_Added AS Attachment_Added,
        Invoicing_Status AS Invoicing_Status,
        TSR_Amt AS TSR_Amt,
        Config AS Config,
        Table_Refresh_Date AS Table_Refresh_Date
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        FROM source_data
        )
,type_data as 
(
    select
        cast(SOREQUEST_DATE as TIMESTAMP_NTZ(9)) as SOREQUEST_DATE,
        cast(SO_NUMBER as VARCHAR(16777216)) as SO_NUMBER,
        cast(REQUESTOR as VARCHAR(16777216)) as REQUESTOR,
        cast(CUSTOMER_FAB_2_CUSTOMER_GROUP as VARCHAR(16777216)) as CUSTOMER_FAB_2_CUSTOMER_GROUP,
        cast(CUSTOMER_FAB_2_OFFICE as VARCHAR(16777216)) as CUSTOMER_FAB_2_OFFICE,
        cast(FAB as VARCHAR(16777216)) as FAB,
        cast(BU as VARCHAR(16777216)) as BU,
        cast(PONUMBER as VARCHAR(16777216)) as PONUMBER,
        cast(QUOTE_NUMBER as VARCHAR(16777216)) as QUOTE_NUMBER,
        cast(CUSTOMER_FAB_2 as VARCHAR(16777216)) as CUSTOMER_FAB_2,
        cast(EST_HOURS as NUMBER(38,10)) as EST_HOURS,
        cast(SOSTART as TIMESTAMP_NTZ(9)) as SOSTART,
        cast(SOEND as TIMESTAMP_NTZ(9)) as SOEND,
        cast(BUSINESS as VARCHAR(16777216)) as BUSINESS,
        cast(SERVICE_TYPE as VARCHAR(16777216)) as SERVICE_TYPE,
        cast(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION,
        cast(SN as VARCHAR(16777216)) as SN,
        cast(CREDIT_CHECK as VARCHAR(16777216)) as CREDIT_CHECK,
        cast(DECOM as VARCHAR(16777216)) as DECOM,
        cast(REQUEST_COMMENTS as VARCHAR(16777216)) as REQUEST_COMMENTS,
        cast(SIG_COMMENTS as VARCHAR(16777216)) as SIG_COMMENTS,
        cast(UPDATES_FROM_FIELD as VARCHAR(16777216)) as UPDATES_FROM_FIELD,
        cast(SIG_NOTES_TO_FIELD as VARCHAR(16777216)) as SIG_NOTES_TO_FIELD,
        cast(TOTAL_TSRAMOUNT_INPUT as NUMBER(38,10)) as TOTAL_TSRAMOUNT_INPUT,
        cast(ATTACHMENT_ADDED as VARCHAR(16777216)) as ATTACHMENT_ADDED,
        cast(INVOICING_STATUS as VARCHAR(16777216)) as INVOICING_STATUS,
        cast(TSR_AMT as VARCHAR(16777216)) as TSR_AMT,
        cast(CONFIG as VARCHAR(16777216)) as CONFIG,
        cast(TABLE_REFRESH_DATE as TIMESTAMP_NTZ(9)) as TABLE_REFRESH_DATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data