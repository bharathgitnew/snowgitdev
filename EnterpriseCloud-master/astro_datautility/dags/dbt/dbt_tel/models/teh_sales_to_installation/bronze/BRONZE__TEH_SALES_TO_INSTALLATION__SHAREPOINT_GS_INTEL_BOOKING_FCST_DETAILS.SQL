{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SHAREPOINT_GS_INTEL_BOOKING_FCST_DETAILS',
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
    SourceData._Filename AS _FILENAME,
    SourceData._Filedate AS _FILEDATE,
    SourceData.JSONFIELD:"Account Code"::string AS AccountCode,
    SourceData.JSONFIELD:"Account Name"::string AS AccountName,
    SourceData.JSONFIELD:"Area"::string AS Area,
    SourceData.JSONFIELD:"AreaName"::string AS AreaName,
    SourceData.JSONFIELD:"BU"::string AS BusinessUnitCode,
    SourceData.JSONFIELD:"BU Name"::string AS BusinessUnitName,
    SourceData.JSONFIELD:"Booking Amount(\)"::string AS BookingAmount,
    SourceData.JSONFIELD:"Booking Amount(\100M)"::string AS BookingAmount100M,
    SourceData.JSONFIELD:"Booking Month"::string AS BookingMonth,
    SourceData.JSONFIELD:"CST Flag"::string AS CSTFlag,
    SourceData.JSONFIELD:"Customer Code"::string AS CustomerCode,
    SourceData.JSONFIELD:"Customer Name"::string AS CustomerName,
    SourceData.JSONFIELD:"End User Code"::string AS EndUserCode,
    SourceData.JSONFIELD:"End User Name"::string AS EndUserName,
    SourceData.JSONFIELD:"FY"::string AS FiscalYear,
    SourceData.JSONFIELD:"Opportunity"::string AS Opportunity,
    SourceData.JSONFIELD:"Product Name"::string AS ProductName,
    
    SourceData.JSONFIELD:"QT"::string AS Quarter,
    SourceData.JSONFIELD:"SO"::string AS SalesOrderNumber,
    SourceData.JSONFIELD:"SUB BU"::string AS SubBusinessUnitName,
    SourceData.JSONFIELD:"Sales Category Code"::string AS SalesCategoryCode,
    SourceData.JSONFIELD:"Sales Category Name"::string AS SalesCategoryName,
    SourceData.JSONFIELD:"KA"::string AS KA,
    SourceData.JSONFIELD:"LEVEL"::string AS LEVEL,
    SourceData.JSONFIELD:"Level2"::string AS Level2,
    SourceData.JSONFIELD:"Q'ty"::string AS Quantity,
    SourceData.JSONFIELD:"EU Request Date"::string AS EuropeRequestDate,
    SourceData.JSONFIELD:"Delivery Date"::string AS DeliveryDate,
    SourceData.JSONFIELD:"Custom Clearence Date"::string AS CustomClearenceDate,
    SourceData.JSONFIELD:"On Dock Date"::string AS OnDockDate,
    SourceData.JSONFIELD:"Sales Date"::string AS SalesDate,
    SourceData.JSONFIELD:"Machine Serial NO"::string AS MachineSerialNumber,
    SourceData.JSONFIELD:"Dist Flag"::string AS DistributionFlag,
    SourceData.JSONFIELD:"Loan Flag"::string AS LoanFlag,
    SourceData.JSONFIELD:"Investment Code"::string AS InvestmentCode,
    SourceData.JSONFIELD:"POR"::string AS ProcessOfRecord,
    SourceData.JSONFIELD:"Back Up"::string AS BackUp,
    SourceData.JSONFIELD:"Degree of sales Uncertainty"::string AS DegreeOfSalesUncertainty,
    SourceData.JSONFIELD:"Investment Sub Code"::string AS InvestmentSubCode,
    SourceData.JSONFIELD:"Device Code(Lv1)"::string AS Device1Code,
    SourceData.JSONFIELD:"Device Name(Lv1)"::string AS Device1Name,
    SourceData.JSONFIELD:"Device Code(Lv2)"::string AS Device2Code,
    SourceData.JSONFIELD:"Device Name(Lv2)"::string AS Device2Name,
(SELECT NEXT_FILE_INGESTION_LOG_ID FROM incremental_FileIngestionLogId) AS FileIngestionLogId
FROM {{ source("SHAREPOINT", "GS_INTEL_BOOKING_FCST_DETAILS") }} SourceData
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