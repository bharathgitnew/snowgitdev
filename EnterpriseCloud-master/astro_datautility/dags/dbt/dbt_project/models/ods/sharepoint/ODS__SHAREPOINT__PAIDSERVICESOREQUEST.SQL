/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Repository\EnterpriseCloud\Snowflake\LZ_2_ODS-Sharepoint\PaidServiceSORequest__SP_PaidServiceSORequest.SQL 
-newFile C:\Repository\EnterpriseCloud\dbt\lz_to_ods\models\sharepoint\PaidServiceSORequest.SQL 
-materialized incremental
-alias PaidServiceSORequest 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema SHAREPOINT
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/11/2022 8:35:02 AM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='PaidServiceSORequest',
    unique_key = ['DocumentID']
) }}


with source_data as 
(
    SELECT
            DataItems.Value:"ID"::VARCHAR AS DocumentID,
            DataItems.Value:"SORequest_x0020_Date"::VARCHAR AS SORequestDate,
            DataItems.Value:"SO_x0020__x0023_"::VARCHAR AS SONumber,
            DataItems.Value:"Requestor"::VARCHAR AS Requestor,
            DataItems.Value:"Customer_x0020_Fab_x0020_2_x003a_Customer_x0020_Group":LookupValue::VARCHAR AS CustomerFabGroup,
            DataItems.Value:"Customer_x0020_Fab_x0020_2_x003a_Office":LookupValue::VARCHAR AS CustomerFabOffice,
            DataItems.Value:"Fab"::VARCHAR AS Fab,
            DataItems.Value:"BU"::VARCHAR AS BU,
            DataItems.Value:"PONumber"::VARCHAR AS PONumber,
            DataItems.Value:"Quote_x0020_Number"::VARCHAR AS QuoteNumber,
            DataItems.Value:"Customer_x0020_Fab_x0020_2":LookupValue::VARCHAR AS CustomerFab,
            DataItems.Value:"Est_x0020_Hours"::NUMBER(38,10) AS EstimatedHours,
            DataItems.Value:"SOStart"::VARCHAR AS SOStart,
            DataItems.Value:"SOEnd"::VARCHAR AS SOEnd,
            DataItems.Value:"Business"::VARCHAR AS Business,
            DataItems.Value:"Service_x0020_Type"::VARCHAR AS ServiceType,
            DataItems.Value:"Description0"::VARCHAR AS Description,
            DataItems.Value:"SN"::VARCHAR AS SerialNumber,
            DataItems.Value:"Credit_x0020_Check"::VARCHAR AS CreditCheck,
            DataItems.Value:"Decom"::VARCHAR AS Decomission,
            DataItems.Value:"Request_x0020_Comments"::VARCHAR AS RequestComments,
            DataItems.Value:"SIG_x0020_Comments"::VARCHAR AS SIGComments,
            DataItems.Value:"Field_x0020_Updates"::VARCHAR AS FieldUpdates,
            DataItems.Value:"SIG_x0020_Notes_x0020_to_x0020_Field"::VARCHAR AS SIGNotesToField,
            DataItems.Value:"Total_x0020_TSRAmount_x0020_Input"::NUMBER(38,10) AS TotalTSRAmountInput,
            DataItems.Value:"Invoicing_x0020_Status"::VARCHAR AS InvoicingStatus,
            DataItems.Value:"TSR_x0020_Amt"::NUMBER(38,10) AS TSRAmount,
            DataItems.Value:"PO_x0023__x0020_in_x0020_Module_x003a_Config":LookupValue::VARCHAR AS POInModuleConfiguration
       FROM {{ source("SHAREPOINT", "PAID_SERVICE_SO_REQUEST") }} SourceData 
        , LATERAL FLATTEN (input => JsonField:Data) DataItems  
        {% if is_incremental() %} WHERE _FileDate > CURRENT_DATE 
        {% else %} QUALIFY (ROW_NUMBER() OVER (PARTITION BY DataItems.Value:"ID"::VARCHAR ORDER BY _FileDate DESC )) = 1 
        {% endif %}
        )
,transform_data as
(
    SELECT 
            source_data.DOCUMENTID AS DocumentID,
            TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.SOREQUESTDATE , '/Date(' , '' ) , ')/' , '' ) ) AS SORequestDate,
            source_data.SONUMBER AS SONumber,
            source_data.REQUESTOR AS Requestor,
            source_data.CUSTOMERFABGROUP AS CustomerFabGroup,
            source_data.CUSTOMERFABOFFICE AS CustomerFabOffice,
            source_data.FAB AS Fab,
            source_data.BU AS BU,
            source_data.PONUMBER AS PONumber,
            source_data.QUOTENUMBER AS QuoteNumber,
            source_data.CUSTOMERFAB AS CustomerFab,
            source_data.ESTIMATEDHOURS AS EstimatedHours,
            TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.SOSTART , '/Date(' , '' ) , ')/' , '' ) ) AS SOStart,
            TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.SOEND , '/Date(' , '' ) , ')/' , '' ) ) AS SOEnd,
            source_data.BUSINESS AS Business,
            source_data.SERVICETYPE AS ServiceType,
            source_data.DESCRIPTION AS Description,
            source_data.SERIALNUMBER AS SerialNumber,
            source_data.CREDITCHECK AS CreditCheck,
            source_data.DECOMISSION AS Decomission,
            source_data.REQUESTCOMMENTS AS RequestComments,
            source_data.SIGCOMMENTS AS SIGComments,
            source_data.FIELDUPDATES AS FieldUpdates,
            source_data.SIGNOTESTOFIELD AS SIGNotesToField,
            source_data.TOTALTSRAMOUNTINPUT AS TotalTSRAmountInput,
            source_data.INVOICINGSTATUS AS InvoicingStatus,
            source_data.TSRAMOUNT AS TSRAmount,
            source_data.POINMODULECONFIGURATION AS POInModuleConfiguration, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        --WHERE source_data.ROWNUM = 1
        )
,type_data as 
(
    select
        cast(DOCUMENTID as NUMBER(38,0)) as DOCUMENTID,
        cast(SOREQUESTDATE as TIMESTAMP_NTZ(9)) as SOREQUESTDATE,
        cast(SONUMBER as VARCHAR(16777216)) as SONUMBER,
        cast(REQUESTOR as VARCHAR(16777216)) as REQUESTOR,
        cast(CUSTOMERFABGROUP as VARCHAR(16777216)) as CUSTOMERFABGROUP,
        cast(CUSTOMERFABOFFICE as VARCHAR(16777216)) as CUSTOMERFABOFFICE,
        cast(FAB as VARCHAR(16777216)) as FAB,
        cast(BU as VARCHAR(16777216)) as BU,
        cast(PONUMBER as VARCHAR(16777216)) as PONUMBER,
        cast(QUOTENUMBER as VARCHAR(16777216)) as QUOTENUMBER,
        cast(CUSTOMERFAB as VARCHAR(16777216)) as CUSTOMERFAB,
        cast(ESTIMATEDHOURS as NUMBER(38,10)) as ESTIMATEDHOURS,
        cast(SOSTART as TIMESTAMP_NTZ(9)) as SOSTART,
        cast(SOEND as TIMESTAMP_NTZ(9)) as SOEND,
        cast(BUSINESS as VARCHAR(16777216)) as BUSINESS,
        cast(SERVICETYPE as VARCHAR(16777216)) as SERVICETYPE,
        cast(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION,
        cast(SERIALNUMBER as VARCHAR(16777216)) as SERIALNUMBER,
        cast(CREDITCHECK as VARCHAR(16777216)) as CREDITCHECK,
        cast(DECOMISSION as VARCHAR(16777216)) as DECOMISSION,
        cast(REQUESTCOMMENTS as VARCHAR(16777216)) as REQUESTCOMMENTS,
        cast(SIGCOMMENTS as VARCHAR(16777216)) as SIGCOMMENTS,
        cast(FIELDUPDATES as VARCHAR(16777216)) as FIELDUPDATES,
        cast(SIGNOTESTOFIELD as VARCHAR(16777216)) as SIGNOTESTOFIELD,
        cast(TOTALTSRAMOUNTINPUT as NUMBER(38,10)) as TOTALTSRAMOUNTINPUT,
        cast(INVOICINGSTATUS as VARCHAR(16777216)) as INVOICINGSTATUS,
        cast(TSRAMOUNT as NUMBER(38,10)) as TSRAMOUNT,
        cast(POINMODULECONFIGURATION as VARCHAR(16777216)) as POINMODULECONFIGURATION,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data