/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Repository\EnterpriseCloud\Snowflake\LZ_2_ODS-Sharepoint\Contract_Flex_TSRs__SP_Contract_TSRs.SQL
-newFile C:\Repository\EnterpriseCloud\dbt\lz_to_ods\models\sharepoint\ServiceContractsFlextsrs.SQL
-materialized incremental
-alias ServiceContractsFlextsrs
-incremental_strategy merge
-envVariable <<LZ>>
-sourceSchema SHAREPOINT
-sourceDatabase LZ_DEV
-useDistinct no
model file generated on: 1/11/2022 8:35:01 AM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SHAREPOINT_SERVICECONTRACTSFLEXTSRS',
    unique_key = ['DOCUMENTID']
) }}


with source_data as
(
SELECT
            DataItems.Value:ID::NUMBER AS DocumentID,
            DataItems.Value:"RevRec_x0020_Month"::VARCHAR AS RevRecDate,
            DataItems.Value:"RevRec_x0020_Month0"::VARCHAR AS RevRecMonth,
            DataItems.Value:"Sold_x002d_To_x0020_Code"::NUMBER AS SoldToCode,
            DataItems.Value:"Serial_x0020_Number"::VARCHAR AS SerialNumber,
            DataItems.Value:"Quote_x0020_Num_x003a_Contract_x0020__x0023_":"LookupValue"::VARCHAR AS ContractNumber,
            DataItems.Value:"SO_x0020__x0023_"::VARCHAR AS SONumber,
            DataItems.Value:"Customer"::VARCHAR AS Customer,
            DataItems.Value:"Customer_x0020_Code"::VARCHAR AS CustomerCode,
            DataItems.Value:"Office"::VARCHAR AS Office,
            DataItems.Value:"Office_x0020_Code"::NUMBER AS OfficeCode,
            DataItems.Value:"BU_x0020_Code"::NUMBER AS BUCode,
            DataItems.Value:"Product_x0020_Type_x0020_Code"::VARCHAR AS ProductTypeCode,
            DataItems.Value:"Finance_x0020_TSR_x0020_Hours"::NUMBER(38,10) AS FinanceTSRHours,
            DataItems.Value:"Finance_x0020_Revenue_x0020_Amount"::NUMBER(38,10) AS FinanceRevenueAmount,
            DataItems.Value:"TSR_x0020_Hours"::NUMBER AS TSRHours,
            DataItems.Value:"TSR_x0020_Amounts"::NUMBER(38,10) AS TSRAmount,
            DataItems.Value:"Modified"::VARCHAR AS Modified,
            DataItems.Value:"Modified_x0020_By"::VARCHAR AS ModifiedBy,
            DataItems.Value:"Comments"::VARCHAR AS Comments
        FROM {{ source("SHAREPOINT", "SERVICE_CONTRACTS_FLEX_TSRS") }} SourceData
        , LATERAL FLATTEN (input => JsonField:Data) DataItems
        {% if is_tel_incremental() %} WHERE _FileDate = IFNULL((SELECT MAX(_FileDate) FROM {{ source("SHAREPOINT", "SERVICE_CONTRACTS_FLEX_TSRS") }}),'1970-01-01')
        {% else %} QUALIFY (ROW_NUMBER() OVER (PARTITION BY DataItems.Value:ID::NUMBER ORDER BY _FileDate DESC )) = 1
        {% endif %}

        )
,transform_data as
(
 SELECT
        source_data.DOCUMENTID AS DOCUMENTID,
        TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.REVRECDATE , '/Date(' , '' ) , ')/' , '' ) ) AS REVRECDATE,
        source_data.REVRECMONTH AS REVRECMONTH,
        source_data.SOLDTOCODE AS SOLDTOCODE,
        source_data.SERIALNUMBER AS SERIALNUMBER,
        source_data.CONTRACTNUMBER AS CONTRACTNUMBER,
        source_data.SONUMBER AS SONUMBER,
        source_data.CUSTOMER AS CUSTOMER,
        source_data.CUSTOMERCODE AS CUSTOMERCODE,
        source_data.OFFICE AS OFFICE,
        source_data.OFFICECODE AS OFFICECODE,
        source_data.BUCODE AS BUCODE,
        source_data.PRODUCTTYPECODE AS PRODUCTTYPECODE,
        source_data.FINANCETSRHOURS AS FINANCETSRHOURS,
        source_data.FINANCEREVENUEAMOUNT AS FINANCEREVENUEAMOUNT,
        source_data.TSRHOURS AS TSRHOURS,
        source_data.TSRAMOUNT AS TSRAMOUNT,
        TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.MODIFIED , '/Date(' , '' ) , ')/' , '' ) ) AS MODIFIED,
        REPLACE ( source_data.MODIFIEDBY , 'i:0#.w|' , '' ) AS MODIFIEDBY,
        source_data.COMMENTS AS COMMENTS,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data

        )
,type_data as
(
    select
        cast(DOCUMENTID as NUMBER(38,0)) as DOCUMENTID,
        cast(REVRECDATE as TIMESTAMP_NTZ(9)) as REVRECDATE,
        cast(REVRECMONTH as VARCHAR(16777216)) as REVRECMONTH,
        cast(SOLDTOCODE as NUMBER(38,0)) as SOLDTOCODE,
        cast(SERIALNUMBER as VARCHAR(16777216)) as SERIALNUMBER,
        cast(CONTRACTNUMBER as VARCHAR(16777216)) as CONTRACTNUMBER,
        cast(SONUMBER as VARCHAR(16777216)) as SONUMBER,
        cast(CUSTOMER as VARCHAR(16777216)) as CUSTOMER,
        cast(CUSTOMERCODE as VARCHAR(16777216)) as CUSTOMERCODE,
        cast(OFFICE as VARCHAR(16777216)) as OFFICE,
        cast(OFFICECODE as NUMBER(38,0)) as OFFICECODE,
        cast(BUCODE as NUMBER(38,0)) as BUCODE,
        cast(PRODUCTTYPECODE as VARCHAR(16777216)) as PRODUCTTYPECODE,
        cast(FINANCETSRHOURS as NUMBER(38,10)) as FINANCETSRHOURS,
        cast(FINANCEREVENUEAMOUNT as NUMBER(38,10)) as FINANCEREVENUEAMOUNT,
        cast(TSRHOURS as NUMBER(38,10)) as TSRHOURS,
        cast(TSRAMOUNT as NUMBER(38,10)) as TSRAMOUNT,
        cast(MODIFIEDBY as VARCHAR(16777216)) as MODIFIEDBY,
        cast(COMMENTS as VARCHAR(16777216)) as COMMENTS,
        cast(MODIFIED as TIMESTAMP_NTZ(9)) as MODIFIED,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data