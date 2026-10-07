{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SHAREPOINT_GS_INTEL_BOOKING_BUDGET_DETAILS',
    unique_key = []
) }}

with incremental_FileIngestionLogId as
(
    SELECT
        COALESCE(MAX(FileIngestionLogId),0)+1 AS NEXT_FILE_INGESTION_LOG_ID
    FROM {{ this }}
    WHERE _FILEDATE NOT IN (SELECT _FILEDATE FROM {{this}})
), source_data as 
(
SELECT
 _Filename as _FILENAME
,_Filedate as _FILEDATE
,JSONFIELD:"Account Code"::STRING AS AccountCode
,JSONFIELD:"Account Name"::STRING AS AccountName
,JSONFIELD:"Area"::STRING AS Area
,JSONFIELD:"AreaName"::STRING AS AreaName
,JSONFIELD:"BU"::STRING AS BusinessUnitCode
,JSONFIELD:"BU Name"::STRING AS BusinessUnitName
,JSONFIELD:"Booking Amount(\)"::STRING AS BookingAmount
,JSONFIELD:"Booking Amount(\100M)"::STRING AS BookingAmount100M
,JSONFIELD:"Booking Month"::STRING AS BookingMonth
,JSONFIELD:"CST Flag"::STRING AS CSTFlag
,JSONFIELD:"Customer Code"::STRING AS CustomerCode
,JSONFIELD:"Customer Name"::STRING AS CustomerName
,JSONFIELD:"End User Code"::STRING AS EndUserCode
,JSONFIELD:"End User Name"::STRING AS EndUserName
,JSONFIELD:"FY"::STRING AS FiscalYear
,JSONFIELD:"Opportunity"::STRING AS Opportunity
,JSONFIELD:"Product Name"::STRING AS ProductName
,JSONFIELD:"QT"::STRING AS Quarter
,JSONFIELD:"SO"::STRING AS SalesOrderNumber
,JSONFIELD:"SUB BU"::STRING AS SubBusinessUnitName
,JSONFIELD:"Sales Category Code"::STRING AS SalesCategoryCode
,JSONFIELD:"Sales Category Name"::STRING AS SalesCategoryName

,JSONFIELD:"KA"::STRING AS KA
,JSONFIELD:"LEVEL"::STRING AS LEVEL
,JSONFIELD:"Level2"::STRING AS Level2
,JSONFIELD:"Q'ty"::STRING AS Quantity
,JSONFIELD:"EU Request Date"::STRING AS EuropeRequestDate
,JSONFIELD:"Delivery Date"::STRING AS DeliveryDate
,JSONFIELD:"Custom Clearence Date"::STRING AS CustomClearenceDate
,JSONFIELD:"On Dock Date"::STRING AS OnDockDate
,JSONFIELD:"Sales Date"::STRING AS SalesDate
,JSONFIELD:"Machine Serial NO"::STRING AS MachineSerialNumber
,JSONFIELD:"Dist Flag"::STRING AS DistributionFlag
,JSONFIELD:"Loan Flag"::STRING AS LoanFlag
,JSONFIELD:"Investment Code"::STRING AS InvestmentCode
,JSONFIELD:"POR"::STRING AS ProcessOfRecord
,JSONFIELD:"Back Up"::STRING AS BackUp
,JSONFIELD:"Degree of sales Uncertainty"::STRING AS DegreeOfSalesUncertainty
,JSONFIELD:"Investment Sub Code"::STRING AS InvestmentSubCode
,JSONFIELD:"Device Code(Lv1)"::STRING AS Device1Code
,JSONFIELD:"Device Name(Lv1)"::STRING AS Device1Name
,JSONFIELD:"Device Code(Lv2)"::STRING AS Device2Code
,JSONFIELD:"Device Name(Lv2)"::STRING AS Device2Name
,(SELECT NEXT_FILE_INGESTION_LOG_ID FROM incremental_FileIngestionLogId) AS FileIngestionLogId
FROM {{ source("SHAREPOINT", "GS_INTEL_BOOKING_BUDGET_DETAILS") }} SourceData
where _FILEDATE> (SELECT COALESCE(MAX(_FILEDATE),'1900-01-01') FROM {{ this }})
),

transform_data as (
    SELECT
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') AS _ROW_HASH,
    _FILENAME,
    _FILEDATE,
    AccountCode,
    AccountName,
    Area,
    AreaName,
    BusinessUnitCode,
    BusinessUnitName,
    CAST(REPLACE(BookingAmount, ',', '') AS DECIMAL(18, 2)) as BookingAmount,
    CAST(REPLACE(BookingAmount100M, ',', '') AS DECIMAL(18, 2)) as BookingAmount100M,
    BookingMonth,
    CSTFlag,
    CustomerCode,
    CustomerName,
    EndUserCode,
    EndUserName,
    FiscalYear,
    Opportunity,
    ProductName,
    Quarter,
    SalesOrderNumber,
    SubBusinessUnitName,
    
    SalesCategoryCode,
    SalesCategoryName,
    KA,
    LEVEL,
    LEVEL2,
    Quantity,
    EuropeRequestDate::DATE AS EuropeRequestDate,
    DeliveryDate::DATE AS DeliveryDate,
    CustomClearenceDate::DATE AS CustomClearenceDate,
    OnDockDate::DATE AS OnDockDate,
    SalesDate::DATE AS SalesDate,
    MachineSerialNumber,
    DistributionFlag,
    LoanFlag,
    InvestmentCode,
    ProcessOfRecord,
    BackUp,
    DegreeOfSalesUncertainty,
    InvestmentSubCode,
    Device1Code,
    Device1Name,
    Device2Code,
    Device2Name,
    FileIngestionLogId

from source_data),

type_data as (
    select 
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        
        _FILENAME,
        cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        AccountCode,
    AccountName,
    Area,
    AreaName,
    BusinessUnitCode,
    BusinessUnitName,
    BookingAmount,
    BookingAmount100M,
    BookingMonth,
    CSTFlag,
    CustomerCode,
    CustomerName,
    EndUserCode,
    EndUserName,
    FiscalYear,
    Opportunity,
    ProductName,
    Quarter,
    SalesOrderNumber,
    SubBusinessUnitName,
    
    SalesCategoryCode,
    SalesCategoryName,
    KA,
    LEVEL,
    LEVEL2,
    Quantity,
    EuropeRequestDate,
    DeliveryDate,
    CustomClearenceDate,
    OnDockDate,
    SalesDate,
    MachineSerialNumber,
    DistributionFlag,
    LoanFlag,
    InvestmentCode,
    ProcessOfRecord,
    BackUp,
    DegreeOfSalesUncertainty,
    InvestmentSubCode,
    Device1Code,
    Device1Name,
    Device2Code,
    Device2Name,
    (SELECT NEXT_FILE_INGESTION_LOG_ID FROM incremental_FileIngestionLogId) AS FileIngestionLogId
        from transform_data
)

select * from type_data