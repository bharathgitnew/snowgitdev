{{ config(
    materialized='view',
    alias='CONSIGNMENT_TRANSACTION'
) }}

with source_data as 
(
    SELECT
        MESSAGE_ID,
        ROSETTANET_LINE_NUMBER,
        TEL_PART_NUMBER,
        CUSTOMER_PART_NUMBER,
        CUSTOMER_PART_DESCRIPTION,
        QUANTITY,
        CONSUMABLE_FLAG,
        TRANSFERRED_FLAG,
        RECONCILED_FLAG,
        STOCK_ROOM,
        TRANSACTION_TYPE,
        TRANSACTION_REASON,
        DATE_CONSUMED,
        DATE_RECEIVED,
        CONTACT_NAME,
        ERROR_MESSAGE,
        FACTORY_NAME,
        ERROR_FLAG,
        TEL_SERIAL_NUMBER,
        INTEL_SERIAL_NUMBER,
        TRANSFERRED_DATE,
        CUSTOMER_TRANSACTION_ID,
        CUSTOMER_TRANSACTION_LINE_ID,
        ROSETTANET_PIP,
        WIINGS_ISSUE_ID,
        SALES_ORG,
        SALES_UNIT,
        CURRENCY,
        NCDR_NUMBER,
        WAREHOUSE,
        ORDER_ORIGIN,
        SERVICE_ORDER_NUMBER,
        POSITION_NUMBER,
        DISPOSITION,
        CONTACT_PHONE,
        SNOWFLAKE_REFRESH_DATE
        FROM {{ ref('COMMON__ROSETTA__CONSIGNMENT_TRANSACTION') }}
)

,transform_data as
(
    SELECT * FROM source_data
)

SELECT * FROM transform_data