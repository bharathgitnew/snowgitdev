{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='GLOBAL_SALES_INTEL_SALES_DETAIL'
) }}
/* 
12/19/2024
No unique_key : The Source file from sharepoint does not contain any unique_key , 
After discussion with Leah, the requirement is to hold old data and insert new data , since data duplication is not an issure threfore inserting all data into target table.

This is a temp solution . Ideally a unique key should be identified and defined to avoid overload data loading.

*/
with source_data as
(
    SELECT 
        _FILENAME,
        _FILEDATE,
        FiscalYear ,
        Quarter,
        SalesMonth ,
        BusinessUnitCode ,
        KA ,
        BusinessUnitName ,
        SubBusinessUnitName ,
        SalesOrderNumber,
        AccountCode ,
        AccountName ,
        CustomerCode ,
        CustomerName,
        EndUserCode ,
        EndUserName ,
        Opportunity ,
        ProductName ,
        Level ,
        Level2 ,
        SalesAmount,
        DirectMargin ,
        Quantity,
        EuropeRequestDate ,
        DeliveryDate ,
        CustomClearenceDate ,
        OnDockDate,
        SalesDate,
        MachineSerialNumber,
        SalesCategoryCode,
        SalesCategoryName ,
        Area ,
        AreaName,
        DistributionFlag,
        LoanFlag,
        CSTFlag,
        InvestmentCode,
        ProcessOfRecord ,
        BackUp ,
        DegreeOfSalesUncertainty ,
        InvestmentSubCode ,
        Device1Code,
        Device1Name ,
        Device2Code ,
        Device2Name,
        SOURCETYPE,
        FileIngestionLogId
    FROM {{ ref('SILVER__TEH_SALES_TO_INSTALLATION__GS_INTEL_SALES') }}
    where _FILENAME not in (Select distinct _FILENAME from {{this}})
    
)

,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        _FILEDATE,
        _FILENAME,
        FiscalYear AS FY,
        Quarter AS QT,
        REGEXP_REPLACE(SalesMonth, '\/Date\\(|\\)\/', '')::DATE AS "Sales Month",
        BusinessUnitCode AS "BU Code",
        KA AS KA,
        BusinessUnitName AS BU,
        SubBusinessUnitName AS "SUB BU",
        SalesOrderNumber AS SO,
        AccountCode AS "Account Code",
        AccountName AS "Account Name",
        CustomerCode AS "Customer Code",
        CustomerName AS "Customer Name",
        EndUserCode AS "End User Code",
        EndUserName AS "End User Name",
        Opportunity,
        ProductName AS "Product Name",
        Level AS Level,
        Level2 AS "Level 2",
        SalesAmount AS "Sales Amount",
        DirectMargin AS "Direct Margin",
        Quantity AS Qty,
        REGEXP_REPLACE(EuropeRequestDate, '\/Date\\(|\\)\/', '')::DATE "EU Request Date",
        REGEXP_REPLACE(DeliveryDate, '\/Date\\(|\\)\/', '')::DATE "Delivery Date",
        REGEXP_REPLACE(CustomClearenceDate, '\/Date\\(|\\)\/', '')::DATE "Custom Clearance Date",
        REGEXP_REPLACE(OnDockDate, '\/Date\\(|\\)\/', '')::DATE "On Dock Date",
        REGEXP_REPLACE(SalesDate, '\/Date\\(|\\)\/', '')::DATE "Sales Date",
        MachineSerialNumber AS "Machine Serial Number",
        SalesCategoryCode AS "Sales Category Code",
        SalesCategoryName AS "Sales Category Name",
        Area AS "Area Code",
        AreaName AS "Area Name",
        DistributionFlag AS "Dist Flag",
        LoanFlag AS "Loan Flag",
        CSTFlag AS "CST Flag",
        InvestmentCode AS "Investment Code",
        ProcessOfRecord as POR,
        BackUp as "Back Up",
        DegreeOfSalesUncertainty AS "Degree of Sales Uncertainty",
        InvestmentSubCode AS "Investment Sub Code",
        Device1Code AS "Device Code Lv1",
        Device1Name AS "Device Name Lv1",
        Device2Code AS "Device Code Lv2",
        Device2Name AS "Device Name Lv2",
        CASE WHEN SourceType IS NOT NULL
                THEN SourceType
            ELSE 
                CASE WHEN _FILENAME ILIKE '%FCST%' THEN 'FCST'
                     WHEN _FILENAME ILIKE '%Budget%' THEN 'Budget'
                     WHEN _FILENAME ILIKE '%Actual%' THEN 'Actual'
                     WHEN _FILENAME ILIKE '%Intel%' THEN 'Intel'
                     ELSE 'NULL'
                END
        END AS "Source Type",
        CASE WHEN _FILEDATE IS NOT NULL
                THEN REGEXP_REPLACE(_FILEDATE, '\/Date\\(|\\)\/', '')::DATE
            ELSE TO_DATE(regexp_replace(_FILENAME, '[^0-9]', ''),'YYYYMMDD')
        END AS  "Source Last Modified Date",
        FileIngestionLogId
        FROM source_data
)

 ,type_data as
 (
     select
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
        FY,
        QT,
        "Sales Month",
        "BU Code",
        KA,
        BU,
        "SUB BU",
        SO,
        "Account Code",
        "Account Name",
        "Customer Code",
        "Customer Name",
        "End User Code",
        "End User Name",
        Opportunity,
        "Product Name",
        Level,
        "Level 2",
        CAST("Sales Amount" AS NUMBER(38,2)) AS "Sales Amount" ,
        CAST("Direct Margin" AS NUMBER(38,2)) AS "Direct Margin",
        CAST(Qty AS NUMBER(38,0)) AS Qty,
        "EU Request Date",
        "Delivery Date",
        "Custom Clearance Date",
        "On Dock Date",
        "Sales Date",
        "Machine Serial Number",
        "Sales Category Code",
        "Sales Category Name",
        "Area Code",
        "Area Name",
        "Dist Flag",
        "Loan Flag",
        "CST Flag",
        "Investment Code",
        POR,
        "Back Up",
        "Degree of Sales Uncertainty",
        "Investment Sub Code",
        "Device Code Lv1",
        "Device Name Lv1",
        "Device Code Lv2",
        "Device Name Lv2",
        "Source Type",
        "Source Last Modified Date",
        CAST(FileIngestionLogId AS NUMBER(38,0)) AS FileIngestionLogId
     from transform_data
     )
select * from type_data