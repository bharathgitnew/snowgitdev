/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-File\GSUSBookingHistory__File_GSUSBookingHistory.SQL
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\file\GSUSBookingHistory.SQL
-materialized incremental
-alias GSUSBookingHistory
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
    alias='GSUSBookingHistory',
    unique_key = []
) }}


with source_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        booking.jsonfield:FiscalYear::STRING AS FiscalYear,
        booking.jsonfield:Quarter::STRING AS Quarter,
        TO_TIMESTAMP_NTZ(TRIM(booking.jsonfield:BookingMonth::STRING,'/Date()/')) as BookingMonth,
        booking.jsonfield:BusinessUnitCode::STRING AS BusinessUnitCode,
        booking.jsonfield:KA::STRING AS KA,
        booking.jsonfield:BusinessUnitName::STRING AS BusinessUnitName,
        booking.jsonfield:SubBusinessUnitName::STRING AS SubBusinessUnitName,
        booking.jsonfield:SalesOrderNumber::STRING AS SalesOrderNumber,
        booking.jsonfield:AccountCode::STRING AS AccountCode,
        booking.jsonfield:AccountName::STRING AS AccountName,
        booking.jsonfield:CustomerCode::STRING AS CustomerCode,
        booking.jsonfield:CustomerName::STRING AS CustomerName,
        booking.jsonfield:EndUserCode::STRING AS EndUserCode,
        booking.jsonfield:EndUserName::STRING AS EndUserName,
        booking.jsonfield:Opportunity::STRING AS Opportunity,
        booking.jsonfield:ProductName::STRING AS ProductName,
        booking.jsonfield:Level::INT AS Level,
        booking.jsonfield:Level2::INT AS Level2,
        booking.jsonfield:BookingAmount::NUMBER AS BookingAmount,
        booking.jsonfield:BookingAmount100M::NUMBER AS BookingAmount100M,
        booking.jsonfield:Quantity::INT AS Quantity,
        TO_TIMESTAMP_NTZ(TRIM(booking.jsonfield:EuropeRequestDate::STRING,'/Date()/')) as EuropeRequestDate,
        TO_TIMESTAMP_NTZ(TRIM(booking.jsonfield:DeliveryDate::STRING,'/Date()/')) as DeliveryDate,
        TO_TIMESTAMP_NTZ(TRIM(booking.jsonfield:CustomClearenceDate::STRING,'/Date()/')) as CustomClearenceDate,
        TO_TIMESTAMP_NTZ(TRIM(booking.jsonfield:OnDockDate::STRING,'/Date()/')) as OnDockDate,
        TO_TIMESTAMP_NTZ(TRIM(booking.jsonfield:SalesDate::STRING,'/Date()/')) as SalesDate,
        booking.jsonfield:MachineSerialNumber::STRING  AS MachineSerialNumber,
        booking.jsonfield:SalesCategoryCode::STRING AS SalesCategoryCode,
        booking.jsonfield:SalesCategoryName::STRING AS SalesCategoryName,
        booking.jsonfield:Area::STRING AS Area,
        booking.jsonfield:AreaName::STRING AS AreaName,
        booking.jsonfield:DistributionFlag::STRING AS DistributionFlag,
        booking.jsonfield:LoanFlag::STRING AS LoanFlag,
        booking.jsonfield:CSTFlag::STRING AS CSTFlag,
        booking.jsonfield:InvestmentCode::STRING AS InvestmentCode,
        booking.jsonfield:ProcessOfRecord::TINYINT AS ProcessOfRecord,
        booking.jsonfield:BackUp::TINYINT AS BackUp,
        booking.jsonfield:DegreeOfSalesUncertainty::TINYINT AS DegreeOfSalesUncertainty,
        booking.jsonfield:InvestmentSubCode::STRING AS InvestmentSubCode,
        booking.jsonfield:Device1Code::STRING AS Device1Code,
        booking.jsonfield:Device1Name::STRING AS Device1Name,
        booking.jsonfield:Device2Code::STRING AS Device2Code,
        booking.jsonfield:Device2Name::STRING AS Device2Name,
        booking.jsonfield:IsIntel::STRING AS IsIntel,
        booking.jsonfield:SourceType::STRING AS SourceType,
        TO_TIMESTAMP_NTZ(TRIM(booking.jsonfield:FileDate::STRING,'/Date()/')) as FileDate
        FROM {{ source("FILE", "GSUSBOOKINGHISTORY") }} booking
        )
,transform_data as
(
    SELECT
        source_data.ACCOUNTCODE,
        source_data.ACCOUNTNAME,
        source_data.AREA,
        source_data.AREANAME,
        source_data.BACKUP,
        source_data.BOOKINGAMOUNT,
        source_data.BOOKINGAMOUNT100M,
        source_data.BOOKINGMONTH,
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
        source_data.DISTRIBUTIONFLAG,
        source_data.ENDUSERCODE,
        source_data.ENDUSERNAME,
        source_data.EUROPEREQUESTDATE,
        IFNULL(source_data._FILEDATE,FILEDATE) AS FileDate,
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
        source_data.SALESCATEGORYCODE,
        source_data.SALESCATEGORYNAME,
        source_data.SALESDATE,
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
        cast(BOOKINGMONTH as TIMESTAMP_NTZ(9)) as BOOKINGMONTH,
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
        cast(BOOKINGAMOUNT as NUMBER(38,0)) as BOOKINGAMOUNT,
        cast(BOOKINGAMOUNT100M as NUMBER(38,0)) as BOOKINGAMOUNT100M,
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