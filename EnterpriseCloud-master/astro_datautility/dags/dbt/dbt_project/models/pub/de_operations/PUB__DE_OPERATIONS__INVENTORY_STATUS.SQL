{{ config(
        materialized='view',
        alias='INVENTORY_STATUS',
        transient=false,
        enabled=true
) }}

with source_data as (
    SELECT
        MATERIAL_NUMBER,
        PLANT,
        STORAGE_LOCATION,
        SLOC_PURPOSE,
        BATCH_NUMBER,
        BASE_UNIT_OF_MEASURE_MATERIAL_BASE_UNIT,
        WMS_BATCH_NUMBER,
        SERIAL_NUMBER,
        STOCK_DATE,
        STOCK_TIME,
        MONTHS_AGING, 
        UNRESTRICTED_QUANTITY,
        STOCK_IN_TRANSFER,
        STOCK_IN_TRANSIT,
        STOCK_IN_QUALITY,
        STOCK_RESTRICTED_BATCHES,
        BLOCKED_STOCK,
        BLOCKED_STOCK_RETURNS,
        MATERIAL_BASE_UNIT_ISO,
        COMPANY_CODE,
        SALES_ORGANIZATION,
        DISTRIBUTION_CHANNEL_CODE,
        DIVISION_CODE,
        MATERIAL_DESCRIPTION,
        STORAGE_LOCATION_NAME,
        DEVICE_CODE,
        PRODUCT_CODE,
        CUSTOMER_CONSIGNMENT_CODE,
        CUSTOMER_CONSIGNMENT_NAME,
        CUSTOMER_LOAN_CODE,
        CUSTOMER_LOAN_NAME,
        BASE_UNIT_OF_MEASURE_BASE_UNIT,
        ISO_CODE_FOR_UNIT_OF_MEASUREMENT,
        MATERIAL_GROUP_1, 
        MATERIAL_GROUP_2, 
        LOCAL_ABC, 
        SPECIFIC_CUSTOMER_ABC, 
        SAFETY_STOCK, 
        REORDER_POINT
    FROM {{ ref('COMMON__REPORTS__INVENTORY_STATUS_REPORT') }}
),

transform_data as (
    SELECT
        *
    FROM source_data
),

type_data as (
    SELECT
        *
    FROM transform_data
)

SELECT * FROM type_data