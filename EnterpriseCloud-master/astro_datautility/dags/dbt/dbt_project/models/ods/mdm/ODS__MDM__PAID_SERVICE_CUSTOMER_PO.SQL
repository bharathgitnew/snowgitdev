/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\Paid_Service_Customer_PO__MDM_Paid_Customer_PO.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\Paid_Service_Customer_PO.SQL 
-materialized incremental
-alias Paid_Service_Customer_PO 
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
    alias='Paid_Service_Customer_PO',
    unique_key = []
) }}


with source_data as 
(
    SELECT 
        jsonfield:"PO Number 2"::VARCHAR AS PO_Number_2, 
        jsonfield:"PO Number 2:SO #"::VARCHAR AS PO_Number_2_SO_Number, 
        jsonfield:"PO Number"::VARCHAR AS PO_Number, 
        jsonfield:"Customer Group"::VARCHAR AS Customer_Group, 
        jsonfield:"Fab 2:Parent Customer Name"::VARCHAR AS Fab_2_Parent_Customer_Name, 
        jsonfield:"Business Issuing PO"::VARCHAR AS Business_Issuing_PO, 
        jsonfield:"Work Start"::VARCHAR AS Work_Start, 
        jsonfield:"Planned End Date"::VARCHAR AS Planned_End_Date, 
        jsonfield:"BU"::VARCHAR AS BU, 
        jsonfield:"Fab"::VARCHAR AS Fab, 
        jsonfield:"Config"::VARCHAR AS Config, 
        jsonfield:"Site Supervisor"::VARCHAR AS Site_Supervisor, 
        jsonfield:"PO Amount"::VARCHAR AS PO_Amount, 
        jsonfield:"PO Amt Calculated"::NUMBER AS PO_Amt_Calculated, 
        jsonfield:"Received Date"::VARCHAR AS Received_Date, 
        jsonfield:"PO Type"::VARCHAR AS PO_Type, 
        jsonfield:"PO Status"::VARCHAR AS PO_Status, 
        jsonfield:"Quote"::VARCHAR AS Quote, 
        jsonfield:"PO Description"::VARCHAR AS PO_Description, 
        jsonfield:"Correct Payment Terms"::VARCHAR AS Correct_Payment_Terms, 
        jsonfield:"Issued to TEA"::VARCHAR AS Issued_To_TEA, 
        jsonfield:"SIG Comments"::VARCHAR AS SIG_Comments, 
        jsonfield:"Table Refresh Date"::VARCHAR AS Table_Refresh_Date 
        FROM {{ source('MDM', 'PAID_SERVICE_CUSTOMER_PO') }} 
	WHERE 1=2
)
/* Adding false filter to the model so that we can enable it for DBT Project Consolidation, related to changes in k-card 34754 */
,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID, 
        SHA2('hash_me') as _ROW_HASH,
        source_data.PO_NUMBER_2 AS PO_Number_2, 
        source_data.PO_NUMBER_2_SO_NUMBER AS PO_Number_2_SO_Number, 
        source_data.PO_NUMBER AS PO_Number, 
        source_data.CUSTOMER_GROUP AS Customer_Group, 
        source_data.FAB_2_PARENT_CUSTOMER_NAME AS Fab_2_Parent_Customer_Name, 
        source_data.BUSINESS_ISSUING_PO AS Business_Issuing_PO, 
        TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.WORK_START , '/Date(' , '' ) , ')/' , '' ) ) AS Work_Start, 
        TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.PLANNED_END_DATE , '/Date(' , '' ) , ')/' , '' ) ) AS Planned_End_Date, 
        source_data.BU AS BU, 
        source_data.FAB AS Fab, 
        source_data.CONFIG AS Config, 
        source_data.SITE_SUPERVISOR AS Site_Supervisor, 
        source_data.PO_AMOUNT AS PO_Amount, 
        source_data.PO_AMT_CALCULATED AS PO_Amt_Calculated, 
        TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.RECEIVED_DATE , '/Date(' , '' ) , ')/' , '' ) ) AS Received_Date, 
        source_data.PO_TYPE AS PO_Type, 
        source_data.PO_STATUS AS PO_Status, 
        source_data.QUOTE AS Quote, 
        source_data.PO_DESCRIPTION AS PO_Description, 
        source_data.CORRECT_PAYMENT_TERMS AS Correct_Payment_Terms, 
        source_data.ISSUED_TO_TEA AS Issued_To_TEA, 
        source_data.SIG_COMMENTS AS SIG_Comments, 
        TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.TABLE_REFRESH_DATE , '/Date(' , '' ) , ')/' , '' ) ) AS Table_Refresh_Date
        FROM source_data
        )
,type_data as 
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
         PO_NUMBER_2,
         PO_NUMBER_2_SO_NUMBER,
         PO_NUMBER,
         CUSTOMER_GROUP,
         FAB_2_PARENT_CUSTOMER_NAME,
         BUSINESS_ISSUING_PO,
        cast(WORK_START as TIMESTAMP_NTZ(9)) as WORK_START,
        cast(PLANNED_END_DATE as TIMESTAMP_NTZ(9)) as PLANNED_END_DATE,
         BU,
         FAB,
         CONFIG,
         SITE_SUPERVISOR,
         PO_AMOUNT,
        cast(PO_AMT_CALCULATED as NUMBER(38,10)) as PO_AMT_CALCULATED,
        cast(RECEIVED_DATE as TIMESTAMP_NTZ(9)) as RECEIVED_DATE,
         PO_TYPE,
         PO_STATUS,
         QUOTE,
         PO_DESCRIPTION,
         CORRECT_PAYMENT_TERMS,
         ISSUED_TO_TEA,
         SIG_COMMENTS,
        cast(TABLE_REFRESH_DATE as TIMESTAMP_NTZ(9)) as TABLE_REFRESH_DATE
    from transform_data
    )
select * from type_data