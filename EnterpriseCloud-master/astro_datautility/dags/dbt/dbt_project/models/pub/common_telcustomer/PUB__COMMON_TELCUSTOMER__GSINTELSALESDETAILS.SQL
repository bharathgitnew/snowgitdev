{{ config(
      materialized='view',
      alias='GSINTELSALESDETAILS',
      transient=false
) }}

with source_data as (
    select
    FY,
    QT,
    SALES_MONTH,
    BU_CODE,
    KA,
    BU,
    SUB_BU,
    SO,
    ACCOUNT_CODE,
    ACCOUNT_NAME,
    CUSTOMER_CODE,
    CUSTOMER_NAME,
    END_USER_CODE,
    END_USER_NAME,
    OPPORTUNITY,
    PRODUCT_NAME,
    LEVEL,
    LEVEL_2,
    SALES_AMOUNT,
    DIRECT_MARGIN,
    QTY,
    EU_REQUEST_DATE,
    DELIVERY_DATE,
    CUSTOM_CLEARANCE_DATE,
    ON_DOCK_DATE,
    SALES_DATE,
    MACHINE_SERIAL_NUMBER,
    SALES_CATEGORY_CODE,
    SALES_CATEGORY_NAME,
    AREA_CODE,
    AREA_NAME,
    DIST_FLAG,
    LOAN_FLAG,
    CST_FLAG,
    INVESTMENT_CODE,
    POR,
    BACK_UP,
    DEGREE_OF_SALES_UNCERTAINTY,
    INVESTMENT_SUB_CODE,
    DEVICE_CODE_LV1,
    DEVICE_NAME_LV1,
    DEVICE_CODE_LV2,
    DEVICE_NAME_LV2,
    SOURCE_TYPE,
    SOURCE_LAST_MODIFIED_DATE
    from {{ ref('COMMON__TELCUSTOMER__GSINTELSALESDETAILS') }}
),

transform_data AS
(
    select * from source_data
)
    select * from transform_data