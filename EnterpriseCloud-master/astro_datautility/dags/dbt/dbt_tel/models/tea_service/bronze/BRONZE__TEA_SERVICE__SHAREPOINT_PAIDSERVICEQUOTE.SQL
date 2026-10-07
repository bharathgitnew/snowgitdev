/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Repository\EnterpriseCloud\Snowflake\LZ_2_ODS-Sharepoint\PaidServiceQuote__SP_PaidServiceQuote.SQL 
-newFile C:\Repository\EnterpriseCloud\dbt\lz_to_ods\models\sharepoint\PaidServiceQuote.SQL 
-materialized incremental
-alias PaidServiceQuote 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema SHAREPOINT
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/11/2022 8:35:02 AM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='SHAREPOINT_PAIDSERVICEQUOTE',
    unique_key = ['DocumentID']
) }}


with source_data as 
(
SELECT
    DataItems.Value:ID::NUMBER AS DocumentID,
    DataItems.Value:"Quote_x0020_Number0"::VARCHAR AS QuoteNumber,
    DataItems.Value:"SO_x0020_Requested_x003f_"::VARCHAR AS SORequested,
    DataItems.Value:"Quote_x0020_Date0"::VARCHAR AS QuoteDate,
    DataItems.Value:"Config"::VARCHAR AS Configuration,
    DataItems.Value:"Product_x0020_Line1"::VARCHAR AS ProductLine,
    DataItems.Value:"Fab_x0020_Location1"::VARCHAR AS FabLocation,
    DataItems.Value:"PO_x0020_Number"::VARCHAR AS PONumber,
    DataItems.Value:"Estimated_x0020_Total0"::NUMBER AS EstimatedTotal,
    DataItems.Value:"Requestor_x0020_Name0"::VARCHAR AS RequestorName,
    DataItems.Value:"Customer0"::VARCHAR AS Customer,
    DataItems.Value:"Start0"::VARCHAR AS StartTime,
    DataItems.Value:"_x0045_nd0"::VARCHAR EndTime,
    DataItems.Value:"Work_x0020_Description0"::VARCHAR AS WorkDescription,
    DataItems.Value:"Decommission0"::VARCHAR AS Decomission,
    DataItems.Value:"Status"::VARCHAR AS QuoteStatus,
    DataItems.Value:"Customer_x0020_Group0"::VARCHAR AS CustomerGroup,
    DataItems.Value:"Serial_x0020_Number0"::VARCHAR AS SerialNumber,
    DataItems.Value:"Tool_x0020_ID0"::VARCHAR AS ToolID,
    DataItems.Value:"Probability0"::VARCHAR AS Probability
  FROM {{ source("SHAREPOINT", "PAID_SERVICE_QUOTE") }} SourceData 
        , LATERAL FLATTEN (input => JsonField:Data) DataItems  
        {% if is_tel_incremental() %} WHERE _FileDate > CURRENT_DATE 
        {% else %} QUALIFY (ROW_NUMBER() OVER (PARTITION BY DataItems.Value:ID::NUMBER ORDER BY _FileDate DESC )) = 1 
        {% endif %}
        )
,transform_data as
(
    SELECT 
       source_data.DOCUMENTID AS DocumentID,
        source_data.QUOTENUMBER AS QuoteNumber,
        source_data.SOREQUESTED AS SORequested,
        TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.QUOTEDATE , '/Date(' , '' ) , ')/' , '' ) ) AS QuoteDate,
        source_data.CONFIGURATION AS Configuration,
        source_data.PRODUCTLINE AS ProductLine,
        source_data.FABLOCATION AS FabLocation,
        source_data.PONUMBER AS PONumber,
        source_data.ESTIMATEDTOTAL AS EstimatedTotal,
        source_data.REQUESTORNAME AS RequestorName,
        source_data.CUSTOMER AS Customer,
        TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.STARTTIME , '/Date(' , '' ) , ')/' , '' ) ) AS StartTime,
        TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.ENDTIME , '/Date(' , '' ) , ')/' , '' ) ) AS EndTime,
        source_data.WORKDESCRIPTION AS WorkDescription,
        source_data.DECOMISSION AS Decomission,
        source_data.QUOTESTATUS AS QuoteStatus,
        source_data.CUSTOMERGROUP AS CustomerGroup,
        source_data.SERIALNUMBER AS SerialNumber,
        source_data.TOOLID AS ToolID,
        source_data.PROBABILITY AS Probability, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data      
        )
, _type_data AS
(
    SELECT
        CAST(DocumentID AS VARCHAR(16777216))  AS DocumentID,
        QuoteNumber,
        SORequested,
        QuoteDate,
        Configuration,
        ProductLine,
        FabLocation,
        PONumber,
        EstimatedTotal,
        RequestorName,
        Customer,
        StartTime,
        EndTime,
        WorkDescription,
        Decomission,
        QuoteStatus,
        CustomerGroup,
        SerialNumber,
        ToolID,
        Probability,
        AUDIT_LOG_ID,
        _ROW_HASH
        from transform_data
)
,type_data as 
(
    select
        cast(DOCUMENTID as VARCHAR(16777216)) as DOCUMENTID,
        cast(QUOTENUMBER as VARCHAR(16777216)) as QUOTENUMBER,
        cast(SOREQUESTED as VARCHAR(16777216)) as SOREQUESTED,
        cast(QUOTEDATE as TIMESTAMP_NTZ(9)) as QUOTEDATE,
        cast(CONFIGURATION as VARCHAR(16777216)) as CONFIGURATION,
        cast(PRODUCTLINE as VARCHAR(16777216)) as PRODUCTLINE,
        cast(FABLOCATION as VARCHAR(16777216)) as FABLOCATION,
        cast(PONUMBER as VARCHAR(16777216)) as PONUMBER,
        cast(ESTIMATEDTOTAL as NUMBER(38,10)) as ESTIMATEDTOTAL,
        cast(REQUESTORNAME as VARCHAR(16777216)) as REQUESTORNAME,
        cast(CUSTOMER as VARCHAR(16777216)) as CUSTOMER,
        cast(STARTTIME as TIMESTAMP_NTZ(9)) as STARTTIME,
        cast(ENDTIME as TIMESTAMP_NTZ(9)) as ENDTIME,
        cast(WORKDESCRIPTION as VARCHAR(16777216)) as WORKDESCRIPTION,
        cast(DECOMISSION as VARCHAR(1677216)) as DECOMISSION,
        cast(QUOTESTATUS as VARCHAR(16777216)) as QUOTESTATUS,
        cast(CUSTOMERGROUP as VARCHAR(16777216)) as CUSTOMERGROUP,
        cast(SERIALNUMBER as VARCHAR(16777216)) as SERIALNUMBER,
        cast(TOOLID as VARCHAR(16777216)) as TOOLID,
        cast(PROBABILITY as VARCHAR(16777216)) as PROBABILITY,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data