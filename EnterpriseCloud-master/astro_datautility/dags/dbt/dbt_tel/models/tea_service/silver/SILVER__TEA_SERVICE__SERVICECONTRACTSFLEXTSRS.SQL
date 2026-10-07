/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-Sharepoint\Contract_Flex_TSRs__ContractFlexTSRs.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\sharepoint\SERVICECONTRACTSFLEXTSRS.SQL
-materialized incremental
-alias SERVICECONTRACTSFLEXTSRS
-incremental_strategy merge
-envVariable <<ODS>>
-sourceSchema SHAREPOINT
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 31-Jan-22 9:15:18 AM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SERVICECONTRACTSFLEXTSRS',
    unique_key = ['Document_ID']
) }}

with
    source_data
    as
    (
        SELECT
            SourceData.DOCUMENTID AS Document_ID,
            SourceData.REVRECDATE AS Rev_Rec_Date,
            SourceData.REVRECMONTH AS Rev_Rec_Month,
            SourceData.SOLDTOCODE AS Sold_To_Code,
            SourceData.SERIALNUMBER AS Serial_Number,
            SourceData.CONTRACTNUMBER AS Contract_Number,
            SourceData.SONUMBER AS SO_Number,
            SourceData.CUSTOMER AS Customer,
            SourceData.CUSTOMERCODE AS Customer_Code,
            SourceData.OFFICE AS Office,
            SourceData.BUCODE AS BU_Code,
            SourceData.OFFICECODE AS Office_Code,
            SourceData.PRODUCTTYPECODE AS Product_Type_Code,
            SourceData.FINANCETSRHOURS AS Finance_TSR_Hours,
            SourceData.FINANCEREVENUEAMOUNT AS Finance_Revenue_Amount,
            SourceData.TSRHOURS AS TSR_Hours,
            SourceData.TSRAMOUNT AS TSR_Amount,
            SourceData.MODIFIED AS Modified,
            SourceData.MODIFIEDBY AS Modified_By,
            SourceData.COMMENTS AS Comments
        FROM
            {{ ref('BRONZE__TEA_SERVICE__SHAREPOINT_SERVICECONTRACTSFLEXTSRS') }} AS SourceData
    )

,
transform_data as
(
        SELECT
    Document_ID,
    Rev_Rec_Date,
    Rev_Rec_Month,
    Sold_To_Code,
    Serial_Number,
    Contract_Number,
    SO_Number,
    Customer,
    Customer_Code,
    Office,
    BU_Code,
    Office_Code,
    Product_Type_Code,
    Finance_TSR_Hours,
    Finance_Revenue_Amount,
    TSR_Hours,
    TSR_Amount,
    Modified,
    Modified_By,
    Comments,
    '{{ invocation_id }}' AS AUDIT_LOG_ID
        , SHA2('hash_me') as _ROW_HASH
-- Adds column to table on full refresh.
FROM source_data
    )

,type_data as
(
    select
        cast(DOCUMENT_ID as NUMBER(38,0)) as DOCUMENT_ID,
        cast(REV_REC_DATE as TIMESTAMP_NTZ(9)) as REV_REC_DATE,
        cast(REV_REC_MONTH as VARCHAR(16777216)) as REV_REC_MONTH,
        cast(SOLD_TO_CODE as NUMBER(38,0)) as SOLD_TO_CODE,
        cast(SERIAL_NUMBER as VARCHAR(16777216)) as SERIAL_NUMBER,
        cast(CONTRACT_NUMBER as VARCHAR(16777216)) as CONTRACT_NUMBER,
        cast(SO_NUMBER as VARCHAR(16777216)) as SO_NUMBER,
        cast(CUSTOMER as VARCHAR(16777216)) as CUSTOMER,
        cast(CUSTOMER_CODE as VARCHAR(16777216)) as CUSTOMER_CODE,
        cast(OFFICE as VARCHAR(16777216)) as OFFICE,
        cast(OFFICE_CODE as NUMBER(38,0)) as OFFICE_CODE,
        cast(BU_CODE as NUMBER(38,0)) as BU_CODE,
        cast(PRODUCT_TYPE_CODE as VARCHAR(16777216)) as PRODUCT_TYPE_CODE,
        cast(FINANCE_TSR_HOURS as NUMBER(38,10)) as FINANCE_TSR_HOURS,
        cast(FINANCE_REVENUE_AMOUNT as NUMBER(38,10)) as FINANCE_REVENUE_AMOUNT,
        cast(TSR_HOURS as NUMBER(38,10)) as TSR_HOURS,
        cast(TSR_AMOUNT as NUMBER(38,10)) as TSR_AMOUNT,
        cast(MODIFIED as VARCHAR(16777216)) as MODIFIED,
        cast(MODIFIED_BY as VARCHAR(16777216)) as MODIFIED_BY,
        cast(COMMENTS as VARCHAR(16777216)) as COMMENTS,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data