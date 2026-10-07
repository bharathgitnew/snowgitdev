/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\PDS_Quote_Request__MDM_PDS_Quote_Request.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\PDS_Quote_Request.SQL 
-materialized incremental
-alias PDS_Quote_Request 
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
    alias='PDS_Quote_Request',
    unique_key = []
) }}


with source_data as 
(
    SELECT  
        jsonfield:"Quote Number"::VARCHAR AS Quote_Number, 
        jsonfield:"Quote Status"::VARCHAR AS Quote_Status, 
        jsonfield:"Quote Date"::VARCHAR AS Quote_Date, 
        jsonfield:"Config"::VARCHAR AS Config, 
        jsonfield:"Config_old"::VARCHAR AS Config_old, 
        jsonfield:"Product Line"::VARCHAR AS Product_Line, 
        jsonfield:"Fab Location"::VARCHAR AS Fab_Location, 
        jsonfield:"PO Number"::VARCHAR AS PO_Number, 
        jsonfield:"Estimated Total"::NUMBER AS Estimated_Total, 
        jsonfield:"Calc Estimated Total"::NUMBER AS Calc_Estimated_Total, 
        jsonfield:"Requestor Name"::VARCHAR AS Requestor_Name, 
        jsonfield:"Customer"::VARCHAR AS Customer, 
        jsonfield:"Start"::VARCHAR AS Start_Time, 
        jsonfield:"End"::VARCHAR AS End_Time, 
        jsonfield:"Work Description"::VARCHAR AS Work_Description, 
        jsonfield:"Decommission"::VARCHAR AS Decommission, 
        jsonfield:"Status"::VARCHAR AS Status, 
        jsonfield:"Customer Group"::VARCHAR AS Customer_Group, 
        jsonfield:"Serial Number"::VARCHAR AS Serial_Number, 
        jsonfield:"Tool ID"::VARCHAR AS Tool_ID, 
        jsonfield:"Probability"::VARCHAR AS Probability, 
        jsonfield:"Table Refresh Date"::VARCHAR AS Table_Refresh_Date 
        FROM {{ source("MDM", "PDS_QUOTE_REQUEST") }} 
        WHERE _FileDate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "PDS_QUOTE_REQUEST") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.QUOTE_NUMBER AS Quote_Number, 
        source_data.QUOTE_STATUS AS Quote_Status, 
        source_data.QUOTE_DATE AS Quote_Date, 
        source_data.CONFIG AS Config, 
        source_data.CONFIG_OLD AS Config_old, 
        source_data.PRODUCT_LINE AS Product_Line, 
        source_data.FAB_LOCATION AS Fab_Location, 
        source_data.PO_NUMBER AS PO_Number, 
        source_data.ESTIMATED_TOTAL AS Estimated_Total, 
        source_data.CALC_ESTIMATED_TOTAL AS Calc_Estimated_Total, 
        source_data.REQUESTOR_NAME AS Requestor_Name, 
        source_data.CUSTOMER AS Customer, 
        TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.START_TIME , '/Date(' , '' ) , ')/' , '' ) ) AS Start_Time, 
        TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.END_TIME , '/Date(' , '' ) , ')/' , '' ) ) AS End_Time, 
        source_data.WORK_DESCRIPTION AS Work_Description, 
        source_data.DECOMMISSION AS Decommission, 
        source_data.STATUS AS Status, 
        source_data.CUSTOMER_GROUP AS Customer_Group, 
        source_data.SERIAL_NUMBER AS Serial_Number, 
        source_data.TOOL_ID AS Tool_ID, 
        source_data.PROBABILITY AS Probability, 
        TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.TABLE_REFRESH_DATE , '/Date(' , '' ) , ')/' , '' ) ) AS Table_Refresh_Date, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID
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