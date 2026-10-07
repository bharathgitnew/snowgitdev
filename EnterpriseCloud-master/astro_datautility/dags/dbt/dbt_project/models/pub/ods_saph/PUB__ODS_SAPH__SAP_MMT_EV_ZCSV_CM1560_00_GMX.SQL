/************
Model file generated from dbtGeneratePubViews: 07.18.2022.18.18.56"
*************/

{{ config(
      materialized='view',
      alias='SAP_MMT_EV_ZCSV_CM1560_00_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        ALLOCATED_ON_QUANTITY,
        ALLOCATED_STOCK_QUANTITY,
        AVAILABLE_ON_QUANTITY,
        AVAILABLE_STOCK_QUANTITY,
        BASE_UNIT,
        BASE_UNIT_ISO,
        CDCHANGENR,
        COMPANY_CODE,
        CUSTOMER_CODE,
        CUSTOMER_CONSIGNMENT_CODE,
        CUSTOMER_CONSIGNMENT_NAME,
        CUSTOMER_LOAN_CODE,
        CUSTOMER_LOAN_NAME,
        DELFLAG,
        DEVICE_CODE,
        DISTRIBUTION_CHANNEL_CODE,
        DIVISION_CODE,
        MATERIAL_BASE_UNIT,
        MATERIAL_BASE_UNIT_ISO,
        MATERIAL_CODE,
        MATERIAL_NAME,
        ORDER_STOCK_QUANTITY,
        PLANT_CODE,
        PRODUCT_CODE,
        PSL_INSDATE,
        PSL_UPDDATE,
        PURCHASE_ORDER_UNIT,
        PURCHASE_ORDER_UNIT_ISO,
        RE_ORDER_POINT_QUANTITY,
        SAFETY_STOCK_QUANTITY,
        SALES_ORGANIZATION_CODE,
        STORAGE_LOCATION_CODE,
        STORAGE_LOCATION_NAME,
        TOTAL_STOCK_QUANTITY,
        _FILEDATE,
        _FILENAME
    from {{ source('ODS__SAPH', 'SAP_MMT_EV_ZCSV_CM1560_00_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data