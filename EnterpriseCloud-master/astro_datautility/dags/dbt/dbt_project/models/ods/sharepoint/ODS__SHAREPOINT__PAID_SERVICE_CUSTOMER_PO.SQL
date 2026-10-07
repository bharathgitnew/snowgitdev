/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Repository\EnterpriseCloud\Snowflake\LZ_2_ODS-Sharepoint\PAID_SERVICE_CUSTOMER_PO__PAID_SERVICE_CUSTOMER_PO.SQL 
-newFile C:\Repository\EnterpriseCloud\dbt\lz_to_ods\models\sharepoint\PAID_SERVICE_CUSTOMER_PO.SQL 
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
    materialized='incremental',
    incremental_strategy='merge',
    alias='PAID_SERVICE_CUSTOMER_PO',
    unique_key = ['PONUMBER',
    'BUSINESSISSUINGPO',
    'PODESCRIPTION',
    'POAMOUNT',
    'RECEIVEDDATE',
    'PODATE']
) }}

with source_data as 
(
Select
        _FILENAME AS _FILENAME,
        _FILEDATE AS _FILEDATE,
        DataItems.value:PO_x0020_Number_x0020_2:LookupValue::STRING AS PONUMBER2
        ,DataItems.value:PO_x0020_Number_x0020_2_x003a_SO:LookupValue::STRING AS PONUMBER2SO
        ,DataItems.value:Title::STRING AS PONUMBER
        ,DataItems.value:Customer_x0020_Group::STRING AS CUSTOMERGROUP
        ,DataItems.value:Fab_x0020_2_x003a_Parent_x0020_C:LookupValue::STRING AS FAB2PARENTCUSTOMERNAME
        ,DataItems.value:Business_x0020_Issuing_x0020_PO:LookupValue::STRING AS BUSINESSISSUINGPO
        ,TO_TIMESTAMP_NTZ(TRIM(DataItems.value:PO_x0020_Date::STRING,'/Date()/')) as PODATE
        ,TO_TIMESTAMP_NTZ(TRIM(DataItems.value:Work_x0020_Start::STRING,'/Date()/')) as WORKSTART
        ,TO_TIMESTAMP_NTZ(TRIM(DataItems.value:Planned_x0020_End_x0020_Date::STRING,'/Date()/')) as PLANNEDENDDATE
        ,DataItems.value:BU::STRING AS BU
        ,DataItems.value:Fab_x0020_2:LookupValue::STRING AS FAB
        ,DataItems.value:Config:LookupValue::STRING AS CONFIG
        ,DataItems.value:PO_x0020_Owner:LookupValue::STRING AS SITESUPERVISOR
        ,DataItems.value:PO_x0020_Amount::STRING AS POAMOUNT
        ,TO_TIMESTAMP_NTZ(TRIM(DataItems.value:Received_x0020_Date::STRING,'/Date()/')) as RECEIVEDDATE
        ,DataItems.value:PO_x0020_Type::STRING AS POTYPE
        ,DataItems.value:PO_x0020_Status::STRING AS POSTATUS
        ,DataItems.value:Quote::STRING AS QUOTE
        ,DataItems.value:PO_x0020_Description::STRING AS PODESCRIPTION
        ,DataItems.value:Correct_x0020_Payment_x0020_Term::STRING AS CORRECTPAYMENTTERMS
        ,DataItems.value:Issued_x0020_to_x0020_TEA::STRING AS ISSUEDTOTEA
        ,DataItems.value:SIG_x0020_Comments::STRING AS SIGCOMMENTS
        ,DataItems.value:Quote_x0020_Requestor_x0020_Name:LookupValue::STRING AS QUOTEREQUESTORNAME
        ,DataItems.value:Quote_x0020_Requestor_x0020_Supe:LookupValue::STRING AS QUOTEREQUESTORSUPERVISOR
        ,DataItems.value:TEH_x0020_HR:LookupValue::STRING AS TEHHR
        ,DataItems.value:Quote_x0020_Number_Lookup:LookupValue::STRING AS QUOTENUMBERLOOKUP
        ,DataItems.value:Quote_x0020_Number_Lookup_x003a_:LookupValue::STRING AS QUOTENUMBERLOOKUPREQUESTORNAME
        ,DataItems.value:Quote_x0020_Number_Lookup_x003a_0:LookupValue::STRING AS QUOTENUMBERLOOKUPREQUESTORSUPERVISOR
        ,DataItems.value:Quote_x0020_Number_Lookup_x003a_1:LookupValue::TIMESTAMP_NTZ AS QUOTENUMBERLOOKUPSTART
        ,DataItems.value:Quote_x0020_Number_Lookup_x003a_2:LookupValue::TIMESTAMP_NTZ AS QUOTENUMBERLOOKUPEND
        ,DataItems.value:Quote_x0020_Number_Lookup_x003a_3:LookupValue::STRING AS QUOTENUMBERLOOKUPCUSTOMER
        ,DataItems.value:Quote_x0020_Number_Lookup_x003a_4:LookupValue::STRING AS QUOTENUMBERLOOKUPFABLOCATION
        ,DataItems.value:Quote_x0020_Number_Lookup_x003a_5:LookupValue::STRING AS QUOTENUMBERLOOKUPPRODUCTLINE
        ,DataItems.value:Quote_x0020_Number_Lookup_x003a_6:LookupValue::STRING AS QUOTENUMBERLOOKUPCONFIG
        ,DataItems.value:Quote_x0020_Number_Lookup_x003a_7:LookupValue::STRING AS QUOTENUMBERLOOKUPBUYER
        ,DataItems.value:REVISEDPODATE::TIMESTAMP_NTZ AS REVISEDPODATE
        ,DataItems.value:REVISEDPOAMOUNT::FLOAT AS REVISEDPOAMOUNT 
    FROM {{ source("SHAREPOINT", "PAID_SERVICE_CUSTOMER_PO") }} SourceData 
        , LATERAL FLATTEN (input => JsonField:Data) DataItems  
        {% if is_incremental() %}  WHERE _FileDate >= IFNULL((SELECT MAX(_FileDate) FROM {{ this }}),'1970-01-01') 
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY DataItems.Value:ID::NUMBER ORDER BY _FileDate DESC )) = 1
        {% endif %}        
        )
,transform_data as
(
SELECT
                source_data._FILENAME,
                source_data._FILEDATE,
                source_data.PONUMBER2 AS PONUMBER2,
                source_data.PONUMBER2SO AS PONUMBER2SO,
                COALESCE(source_data.PONUMBER,'NOVALUE') AS PONUMBER,
                source_data.CUSTOMERGROUP AS CUSTOMERGROUP,
                source_data.FAB2PARENTCUSTOMERNAME AS FAB2PARENTCUSTOMERNAME,
                source_data.BUSINESSISSUINGPO AS BUSINESSISSUINGPO,
                source_data.PODATE AS PODATE,
                source_data.WORKSTART AS WORKSTART,
                source_data.PLANNEDENDDATE AS PLANNEDENDDATE,
                source_data.BU AS BU,
                source_data.FAB AS FAB,
                source_data.CONFIG AS CONFIG,
                source_data.SITESUPERVISOR AS SITESUPERVISOR,
                source_data.POAMOUNT AS POAMOUNT,
                source_data.RECEIVEDDATE AS RECEIVEDDATE,
                source_data.POTYPE AS POTYPE,
                source_data.POSTATUS AS POSTATUS,
                source_data.QUOTE AS QUOTE,
                source_data.PODESCRIPTION AS PODESCRIPTION,
                source_data.CORRECTPAYMENTTERMS AS CORRECTPAYMENTTERMS,
                source_data.ISSUEDTOTEA AS ISSUEDTOTEA,
                source_data.SIGCOMMENTS AS SIGCOMMENTS,
                source_data.QUOTEREQUESTORNAME AS QUOTEREQUESTORNAME,
                source_data.QUOTEREQUESTORSUPERVISOR AS QUOTEREQUESTORSUPERVISOR,
                source_data.TEHHR AS TEHHR,
                source_data.QUOTENUMBERLOOKUP AS QUOTENUMBERLOOKUP,
                source_data.QUOTENUMBERLOOKUPREQUESTORNAME AS QUOTENUMBERLOOKUPREQUESTORNAME,
                source_data.QUOTENUMBERLOOKUPREQUESTORSUPERVISOR AS QUOTENUMBERLOOKUPREQUESTORSUPERVISOR,
                source_data.QUOTENUMBERLOOKUPSTART AS QUOTENUMBERLOOKUPSTART,
                source_data.QUOTENUMBERLOOKUPEND AS QUOTENUMBERLOOKUPEND,
                source_data.QUOTENUMBERLOOKUPCUSTOMER AS QUOTENUMBERLOOKUPCUSTOMER,
                source_data.QUOTENUMBERLOOKUPFABLOCATION AS QUOTENUMBERLOOKUPFABLOCATION,
                source_data.QUOTENUMBERLOOKUPPRODUCTLINE AS QUOTENUMBERLOOKUPPRODUCTLINE,
                source_data.QUOTENUMBERLOOKUPCONFIG AS QUOTENUMBERLOOKUPCONFIG,
                source_data.QUOTENUMBERLOOKUPBUYER AS QUOTENUMBERLOOKUPBUYER,
                source_data.REVISEDPODATE AS REVISEDPODATE,
                source_data.REVISEDPOAMOUNT AS REVISEDPOAMOUNT, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        
)
,type_data as 
(
    select
        cast(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
        cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        cast(PONUMBER2 as VARCHAR(16777216)) as PONUMBER2,
        cast(PONUMBER2SO as VARCHAR(16777216)) as PONUMBER2SO,
        cast(PONUMBER as VARCHAR(16777216)) as PONUMBER,
        cast(CUSTOMERGROUP as VARCHAR(16777216)) as CUSTOMERGROUP,
        cast(FAB2PARENTCUSTOMERNAME as VARCHAR(16777216)) as FAB2PARENTCUSTOMERNAME,
        cast(BUSINESSISSUINGPO as VARCHAR(16777216)) as BUSINESSISSUINGPO,
        cast(PODATE as TIMESTAMP_NTZ(9)) as PODATE,
        cast(WORKSTART as VARCHAR(16777216)) as WORKSTART,
        cast(PLANNEDENDDATE as TIMESTAMP_NTZ(9)) as PLANNEDENDDATE,
        cast(BU as VARCHAR(16777216)) as BU,
        cast(FAB as VARCHAR(16777216)) as FAB,
        cast(CONFIG as VARCHAR(16777216)) as CONFIG,
        cast(SITESUPERVISOR as VARCHAR(16777216)) as SITESUPERVISOR,
        cast(POAMOUNT as VARCHAR(16777216)) as POAMOUNT,
        cast(RECEIVEDDATE as TIMESTAMP_NTZ(9)) as RECEIVEDDATE,
        cast(POTYPE as VARCHAR(16777216)) as POTYPE,
        cast(POSTATUS as VARCHAR(16777216)) as POSTATUS,
        cast(QUOTE as VARCHAR(16777216)) as QUOTE,
        cast(PODESCRIPTION as VARCHAR(16777216)) as PODESCRIPTION,
        cast(CORRECTPAYMENTTERMS as VARCHAR(16777216)) as CORRECTPAYMENTTERMS,
        cast(ISSUEDTOTEA as VARCHAR(16777216)) as ISSUEDTOTEA,
        cast(SIGCOMMENTS as VARCHAR(16777216)) as SIGCOMMENTS,
        cast(QUOTEREQUESTORNAME as VARCHAR(16777216)) as QUOTEREQUESTORNAME,
        cast(QUOTEREQUESTORSUPERVISOR as VARCHAR(16777216)) as QUOTEREQUESTORSUPERVISOR,
        cast(TEHHR as VARCHAR(16777216)) as TEHHR,
        cast(QUOTENUMBERLOOKUP as VARCHAR(16777216)) as QUOTENUMBERLOOKUP,
        cast(QUOTENUMBERLOOKUPREQUESTORNAME as VARCHAR(16777216)) as QUOTENUMBERLOOKUPREQUESTORNAME,
        cast(QUOTENUMBERLOOKUPREQUESTORSUPERVISOR as VARCHAR(16777216)) as QUOTENUMBERLOOKUPREQUESTORSUPERVISOR,
        cast(QUOTENUMBERLOOKUPSTART as TIMESTAMP_NTZ(9)) as QUOTENUMBERLOOKUPSTART,
        cast(QUOTENUMBERLOOKUPEND as TIMESTAMP_NTZ(9)) as QUOTENUMBERLOOKUPEND,
        cast(QUOTENUMBERLOOKUPCUSTOMER as VARCHAR(16777216)) as QUOTENUMBERLOOKUPCUSTOMER,
        cast(QUOTENUMBERLOOKUPFABLOCATION as VARCHAR(16777216)) as QUOTENUMBERLOOKUPFABLOCATION,
        cast(QUOTENUMBERLOOKUPPRODUCTLINE as VARCHAR(16777216)) as QUOTENUMBERLOOKUPPRODUCTLINE,
        cast(QUOTENUMBERLOOKUPCONFIG as VARCHAR(16777216)) as QUOTENUMBERLOOKUPCONFIG,
        cast(QUOTENUMBERLOOKUPBUYER as VARCHAR(16777216)) as QUOTENUMBERLOOKUPBUYER,
        cast(REVISEDPODATE as TIMESTAMP_NTZ(9)) as REVISEDPODATE,
        cast(REVISEDPOAMOUNT as FLOAT) as REVISEDPOAMOUNT,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data