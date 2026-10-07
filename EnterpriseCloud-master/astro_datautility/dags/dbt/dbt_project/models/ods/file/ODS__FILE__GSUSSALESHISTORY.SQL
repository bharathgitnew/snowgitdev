/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-File\GSUSSalesHistory__File_GSUSSalesHistory.SQL
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\file\GSUSSalesHistory.SQL
-materialized incremental
-alias GSUSSalesHistory
-incremental_strategy insert_overwrite
-envVariable <<LZ>>
-sourceSchema FILE
-sourceDatabase LZ_DEV
-useDistinct $false
model file generated on: 1/10/2022 11:56:58 AM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='GSUSSalesHistory',
    unique_key = []
) }}


with source_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        sales.jsonfield:FiscalYear::STRING AS FiscalYear,
        sales.jsonfield:Quarter::STRING AS Quarter,
        TO_TIMESTAMP_NTZ(TRIM(sales.jsonfield:SalesMonth::STRING,'/Date()/')) as SalesMonth,
        sales.jsonfield:BusinessUnitCode::STRING AS BusinessUnitCode,
        sales.jsonfield:KA::STRING AS KA,
        sales.jsonfield:BusinessUnitName::STRING AS BusinessUnitName,
        sales.jsonfield:SubBusinessUnitName::STRING AS SubBusinessUnitName,
        sales.jsonfield:SalesOrderNumber::STRING AS SalesOrderNumber,
        sales.jsonfield:AccountCode::STRING AS AccountCode,
        sales.jsonfield:AccountName::STRING AS AccountName,
        sales.jsonfield:CustomerCode::STRING AS CustomerCode,
        sales.jsonfield:CustomerName::STRING AS CustomerName,
        sales.jsonfield:EndUserCode::STRING AS EndUserCode,
        sales.jsonfield:EndUserName::STRING AS EndUserName,
        sales.jsonfield:Opportunity::STRING AS Opportunity,
        sales.jsonfield:ProductName::STRING AS ProductName,
        sales.jsonfield:Level::INT AS Level,
        sales.jsonfield:Level2::INT AS Level2,
        sales.jsonfield:SalesAmount::NUMBER AS SalesAmount,
        sales.jsonfield:DirectMargin::NUMBER AS DirectMargin,
        sales.jsonfield:SalesAmount100M::NUMBER AS SalesAmount100M,
        sales.jsonfield:DirectMargin100M::NUMBER AS DirectMargin100M,
        sales.jsonfield:Quantity::INT AS Quantity,
        TO_TIMESTAMP_NTZ(TRIM(sales.jsonfield:EuropeRequestDate::STRING,'/Date()/')) as EuropeRequestDate,
        TO_TIMESTAMP_NTZ(TRIM(sales.jsonfield:DeliveryDate::STRING,'/Date()/')) as DeliveryDate,
        TO_TIMESTAMP_NTZ(TRIM(sales.jsonfield:CustomClearenceDate::STRING,'/Date()/')) as CustomClearenceDate,
        TO_TIMESTAMP_NTZ(TRIM(sales.jsonfield:OnDockDate::STRING,'/Date()/')) as OnDockDate,
        TO_TIMESTAMP_NTZ(TRIM(sales.jsonfield:SalesDate::STRING,'/Date()/')) as SalesDate,
        sales.jsonfield:MachineSerialNumber::STRING AS MachineSerialNumber,
        sales.jsonfield:SalesCategoryCode::STRING AS SalesCategoryCode,
        sales.jsonfield:SalesCategoryName::STRING AS SalesCategoryName,
        sales.jsonfield:Area::STRING AS Area,
        sales.jsonfield:AreaName::STRING AS AreaName,
        sales.jsonfield:DistributionFlag::STRING AS DistributionFlag,
        sales.jsonfield:LoanFlag::STRING AS LoanFlag,
        sales.jsonfield:CSTFlag::STRING AS CSTFlag,
        sales.jsonfield:InvestmentCode::STRING AS InvestmentCode,
        sales.jsonfield:ProcessOfRecord::TINYINT AS ProcessOfRecord,
        sales.jsonfield:BackUp::TINYINT AS BackUp,
        sales.jsonfield:DegreeOfSalesUncertainty::TINYINT AS DegreeOfSalesUncertainty,
        sales.jsonfield:InvestmentSubCode::STRING AS InvestmentSubCode,
        sales.jsonfield:Device1Code::STRING AS Device1Code,
        sales.jsonfield:Device1Name::STRING AS Device1Name,
        sales.jsonfield:Device2Code::STRING AS Device2Code,
        sales.jsonfield:Device2Name::STRING AS Device2Name,
        sales.jsonfield:IsIntel::STRING AS IsIntel,
        sales.jsonfield:SourceType::STRING AS SourceType,
        TO_TIMESTAMP_NTZ(TRIM(sales.jsonfield:FileDate::STRING,'/Date()/')) as FileDate
        FROM {{ source("FILE", "GSUSSALESHISTORY") }} sales
        )
,transform_data as
(
    SELECT
        source_data.ACCOUNTCODE,
        source_data.ACCOUNTNAME,
        source_data.AREA,
        source_data.AREANAME,
        source_data.BACKUP,
        source_data.BUSINESSUNITCODE,
        source_data.BUSINESSUNITNAME,
        source_data.CSTFLAG,
        source_data.CUSTOMCLEARENCEDATE,
        source_data.CUSTOMERCODE,
        source_data.CUSTOMERNAME,
        source_data.DEGREEOFSALESUNCERTAINTY,
        source_data.DELIVERYDATE,
        source_data.DEVICE1CODE,
        source_data.DEVICE1NAME,
        source_data.DEVICE2CODE,
        source_data.DEVICE2NAME,
        source_data.DIRECTMARGIN,
        source_data.DIRECTMARGIN100M,
        source_data.DISTRIBUTIONFLAG,
        source_data.ENDUSERCODE,
        source_data.ENDUSERNAME,
        source_data.EUROPEREQUESTDATE,
        IFNULL(source_data.FILEDATE,_FILEDATE) AS FileDate,
        source_data.FISCALYEAR,
        source_data.INVESTMENTCODE,
        source_data.INVESTMENTSUBCODE,
        source_data.ISINTEL,
        source_data.KA,
        source_data.LEVEL,
        source_data.LEVEL2,
        source_data.LOANFLAG,
        source_data.MACHINESERIALNUMBER,
        source_data.ONDOCKDATE,
        source_data.OPPORTUNITY,
        source_data.PROCESSOFRECORD,
        source_data.PRODUCTNAME,
        source_data.QUANTITY,
        source_data.QUARTER,
        source_data.SALESAMOUNT,
        source_data.SALESAMOUNT100M,
        source_data.SALESCATEGORYCODE,
        source_data.SALESCATEGORYNAME,
        source_data.SALESDATE,
        source_data.SALESMONTH,
        source_data.SALESORDERNUMBER,
        source_data.SOURCETYPE,
        source_data.SUBBUSINESSUNITNAME ,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(FISCALYEAR as VARCHAR(16777216)) as FISCALYEAR,
        cast(QUARTER as VARCHAR(16777216)) as QUARTER,
        cast(SALESMONTH as TIMESTAMP_NTZ(9)) as SALESMONTH,
        cast(BUSINESSUNITCODE as VARCHAR(16777216)) as BUSINESSUNITCODE,
        cast(KA as VARCHAR(16777216)) as KA,
        cast(BUSINESSUNITNAME as VARCHAR(16777216)) as BUSINESSUNITNAME,
        cast(SUBBUSINESSUNITNAME as VARCHAR(16777216)) as SUBBUSINESSUNITNAME,
        cast(SALESORDERNUMBER as VARCHAR(16777216)) as SALESORDERNUMBER,
        cast(ACCOUNTCODE as VARCHAR(16777216)) as ACCOUNTCODE,
        cast(ACCOUNTNAME as VARCHAR(16777216)) as ACCOUNTNAME,
        cast(CUSTOMERCODE as VARCHAR(16777216)) as CUSTOMERCODE,
        cast(CUSTOMERNAME as VARCHAR(16777216)) as CUSTOMERNAME,
        cast(ENDUSERCODE as VARCHAR(16777216)) as ENDUSERCODE,
        cast(ENDUSERNAME as VARCHAR(16777216)) as ENDUSERNAME,
        cast(OPPORTUNITY as VARCHAR(16777216)) as OPPORTUNITY,
        cast(PRODUCTNAME as VARCHAR(16777216)) as PRODUCTNAME,
        cast(LEVEL as NUMBER(38,0)) as LEVEL,
        cast(LEVEL2 as NUMBER(38,0)) as LEVEL2,
        cast(SALESAMOUNT as NUMBER(38,0)) as SALESAMOUNT,
        cast(DIRECTMARGIN as NUMBER(38,0)) as DIRECTMARGIN,
        cast(SALESAMOUNT100M as NUMBER(38,0)) as SALESAMOUNT100M,
        cast(DIRECTMARGIN100M as NUMBER(38,0)) as DIRECTMARGIN100M,
        cast(QUANTITY as NUMBER(38,0)) as QUANTITY,
        cast(EUROPEREQUESTDATE as TIMESTAMP_NTZ(9)) as EUROPEREQUESTDATE,
        cast(DELIVERYDATE as TIMESTAMP_NTZ(9)) as DELIVERYDATE,
        cast(CUSTOMCLEARENCEDATE as TIMESTAMP_NTZ(9)) as CUSTOMCLEARENCEDATE,
        cast(ONDOCKDATE as TIMESTAMP_NTZ(9)) as ONDOCKDATE,
        cast(SALESDATE as TIMESTAMP_NTZ(9)) as SALESDATE,
        cast(MACHINESERIALNUMBER as VARCHAR(16777216)) as MACHINESERIALNUMBER,
        cast(SALESCATEGORYCODE as VARCHAR(16777216)) as SALESCATEGORYCODE,
        cast(SALESCATEGORYNAME as VARCHAR(16777216)) as SALESCATEGORYNAME,
        cast(AREA as VARCHAR(16777216)) as AREA,
        cast(AREANAME as VARCHAR(16777216)) as AREANAME,
        cast(DISTRIBUTIONFLAG as VARCHAR(16777216)) as DISTRIBUTIONFLAG,
        cast(LOANFLAG as VARCHAR(16777216)) as LOANFLAG,
        cast(CSTFLAG as VARCHAR(16777216)) as CSTFLAG,
        cast(INVESTMENTCODE as VARCHAR(16777216)) as INVESTMENTCODE,
        cast(PROCESSOFRECORD as NUMBER(38,0)) as PROCESSOFRECORD,
        cast(BACKUP as NUMBER(38,0)) as BACKUP,
        cast(DEGREEOFSALESUNCERTAINTY as NUMBER(38,0)) as DEGREEOFSALESUNCERTAINTY,
        cast(INVESTMENTSUBCODE as VARCHAR(16777216)) as INVESTMENTSUBCODE,
        cast(DEVICE1CODE as VARCHAR(16777216)) as DEVICE1CODE,
        cast(DEVICE1NAME as VARCHAR(16777216)) as DEVICE1NAME,
        cast(DEVICE2CODE as VARCHAR(16777216)) as DEVICE2CODE,
        cast(DEVICE2NAME as VARCHAR(16777216)) as DEVICE2NAME,
        cast(ISINTEL as VARCHAR(16777216)) as ISINTEL,
        cast(SOURCETYPE as VARCHAR(16777216)) as SOURCETYPE,
        cast(FileDate as Timestamp_NTZ) as FileDate,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data