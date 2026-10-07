/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\Paid_Service_SO_Request__MDM_Paid_SO_Request.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\Paid_Service_SO_Request.SQL 
-materialized incremental
-alias Paid_Service_SO_Request 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 7:25:00 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='Paid_Service_SO_Request',
    unique_key = []
) }}


with source_data as 
(
    SELECT 
        jsonfield:"SORequest Date"::VARCHAR AS SORequest_Date, 
        jsonfield:"SO #"::VARCHAR AS SO_Number, 
        jsonfield:"Requestor"::VARCHAR AS Requestor, 
        jsonfield:"Customer Fab 2:Customer Group"::VARCHAR AS Customer_Fab_2_Customer_Group, 
        jsonfield:"Customer Fab 2:Office"::VARCHAR AS Customer_Fab_2_Office, 
        jsonfield:"Fab"::VARCHAR AS Fab, 
        jsonfield:"BU"::VARCHAR AS BU, 
        jsonfield:"PONumber"::VARCHAR AS PONumber, 
        jsonfield:"Quote Number"::VARCHAR AS Quote_Number, 
        jsonfield:"Customer Fab 2"::VARCHAR AS Customer_Fab_2, 
        jsonfield:"Est Hours"::NUMBER AS Est_Hours, 
        jsonfield:"SOStart"::VARCHAR AS SOStart, 
        jsonfield:"SOEnd"::VARCHAR AS SOEnd, 
        jsonfield:"Business"::VARCHAR AS Business, 
        jsonfield:"Service Type"::VARCHAR AS Service_Type, 
        jsonfield:"Description"::VARCHAR AS Description, 
        jsonfield:"SN"::VARCHAR AS SN, 
        jsonfield:"Credit Check"::VARCHAR AS Credit_Check, 
        jsonfield:"Decom"::VARCHAR AS Decom, 
        jsonfield:"Request Comments"::VARCHAR AS Request_Comments, 
        jsonfield:"SIG Comments"::VARCHAR AS SIG_Comments, 
        jsonfield:"Updates from Field"::VARCHAR AS Updates_From_Field, 
        jsonfield:"SIG Notes to Field"::VARCHAR AS SIG_Notes_To_Field, 
        jsonfield:"Total TSRAmount Input"::NUMBER AS Total_TSRAmount_Input, 
        jsonfield:"Attachment Added"::VARCHAR AS Attachment_Added, 
        jsonfield:"Invoicing Status"::VARCHAR AS Invoicing_Status, 
        jsonfield:"TSR Amt"::VARCHAR AS TSR_Amt, 
        jsonfield:"Config"::VARCHAR AS Config, 
        jsonfield:"Table Refresh Date"::VARCHAR AS Table_Refresh_Date 
        FROM {{ source('MDM', 'PAID_SERVICE_SO_REQUEST') }} 
	WHERE 1=2
)
/* Adding false filter to the model so that we can enable it for DBT Project Consolidation, related to changes in k-card 34754 */
,transform_data as
(
    SELECT 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID, 
        SHA2('hash_me') as _ROW_HASH,
        TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.SOREQUEST_DATE , '/Date(' , '' ) , ')/' , '' ) ) AS SORequest_Date, 
        source_data.SO_NUMBER AS SO_Number, 
        source_data.REQUESTOR AS Requestor, 
        source_data.CUSTOMER_FAB_2_CUSTOMER_GROUP AS Customer_Fab_2_Customer_Group, 
        source_data.CUSTOMER_FAB_2_OFFICE AS Customer_Fab_2_Office, 
        source_data.FAB AS Fab, 
        source_data.BU AS BU, 
        source_data.PONUMBER AS PONumber, 
        source_data.QUOTE_NUMBER AS Quote_Number, 
        source_data.CUSTOMER_FAB_2 AS Customer_Fab_2, 
        source_data.EST_HOURS AS Est_Hours, 
        TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.SOSTART , '/Date(' , '' ) , ')/' , '' ) ) AS SOStart, 
        TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.SOEND , '/Date(' , '' ) , ')/' , '' ) ) AS SOEnd, 
        source_data.BUSINESS AS Business, 
        source_data.SERVICE_TYPE AS Service_Type, 
        source_data.DESCRIPTION AS Description, 
        source_data.SN AS SN, 
        source_data.CREDIT_CHECK AS Credit_Check, 
        source_data.DECOM AS Decom, 
        source_data.REQUEST_COMMENTS AS Request_Comments, 
        source_data.SIG_COMMENTS AS SIG_Comments, 
        source_data.UPDATES_FROM_FIELD AS Updates_From_Field, 
        source_data.SIG_NOTES_TO_FIELD AS SIG_Notes_To_Field, 
        source_data.TOTAL_TSRAMOUNT_INPUT AS Total_TSRAmount_Input, 
        source_data.ATTACHMENT_ADDED AS Attachment_Added, 
        source_data.INVOICING_STATUS AS Invoicing_Status, 
        source_data.TSR_AMT AS TSR_Amt, 
        source_data.CONFIG AS Config, 
        TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.TABLE_REFRESH_DATE , '/Date(' , '' ) , ')/' , '' ) ) AS Table_Refresh_Date
        FROM source_data
        )
,type_data as 
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(SOREQUEST_DATE as TIMESTAMP_NTZ(9)) as SOREQUEST_DATE,
         SO_NUMBER,
         REQUESTOR,
         CUSTOMER_FAB_2_CUSTOMER_GROUP,
         CUSTOMER_FAB_2_OFFICE,
         FAB,
         BU,
         PONUMBER,
         QUOTE_NUMBER,
         CUSTOMER_FAB_2,
        cast(EST_HOURS as NUMBER(38,10)) as EST_HOURS,
        cast(SOSTART as TIMESTAMP_NTZ(9)) as SOSTART,
        cast(SOEND as TIMESTAMP_NTZ(9)) as SOEND,
         BUSINESS,
         SERVICE_TYPE,
         DESCRIPTION,
         SN,
         CREDIT_CHECK,
         DECOM,
         REQUEST_COMMENTS,
         SIG_COMMENTS,
         UPDATES_FROM_FIELD,
         SIG_NOTES_TO_FIELD,
        cast(TOTAL_TSRAMOUNT_INPUT as NUMBER(38,10)) as TOTAL_TSRAMOUNT_INPUT,
         ATTACHMENT_ADDED,
         INVOICING_STATUS,
         TSR_AMT,
         CONFIG,
        cast(TABLE_REFRESH_DATE as TIMESTAMP_NTZ(9)) as TABLE_REFRESH_DATE
    from transform_data
    )
select * from type_data