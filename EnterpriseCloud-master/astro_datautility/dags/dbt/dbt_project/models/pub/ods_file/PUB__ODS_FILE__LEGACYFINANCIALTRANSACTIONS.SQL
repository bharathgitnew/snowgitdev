/************
Model file generated from dbtGeneratePubViews: 03.16.2022.12.10.20"
*************/

{{ config(
      materialized='view',
      alias='LEGACYFINANCIALTRANSACTIONS',
      transient=false
) }}

with source_data as (
    SELECT
        _FILENAME,
        _FILEDATE,
        FINANCIALDOCUMENTLINEID,
        FINANCIALDOCUMENTDATEKEY,
        FINANCIALTRANSACTIONDATEKEY,
        FISCALMONTHKEY,
        CALENDARDATEKEY,
        EMPLOYEEID,
        TRANSACTIONREFERENCEID,
        ITEM,
        SERVICECONTRACTNUMBER,
        MACHINESERIALNUMBER,
        WAREHOUSE,
        STATUTORYMAPPING,
        AMOUNT,
        REQUISITIONID,
        PURCHASEORDERNUMBER,
        PURCHASEORDERNUMBERANDLINE,
        ORDERTYPEANDSALESANDSERVICEORDERNUMBERANDLINE,
        SALESANDSERVICEORDERNUMBERANDLINE,
        PRODUCTIONORDER,
        SOLDTOBPID,
        SUPPLIERCODE,
        CUSTOMERCODE,
        COMPANYCODE,
        DEPARTMENTCODE,
        OFFICECODE,
        FINANCIALPRODUCTTYPECODE,
        SEGMENTCODE,
        FINALIZEDTRANSACTIONTYPECODE,
        FINANCIALACCOUNTNUMBER,
        COSTCENTER,
        PROJECT,
        CONFIGURATION
    from {{ source('ODS__FILE', 'LEGACYFINANCIALTRANSACTIONS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data