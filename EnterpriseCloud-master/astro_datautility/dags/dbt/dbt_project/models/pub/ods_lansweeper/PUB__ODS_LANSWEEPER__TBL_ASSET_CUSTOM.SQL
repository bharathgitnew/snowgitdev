/************
Model file generated from dbtGeneratePubViews: 03.09.2022.17.40.39"
*************/

{{ config(
      materialized='view',
      alias='TBL_ASSET_CUSTOM',
      transient=false
) }}

with source_data as (
    SELECT
        CUST_ID,
        ASSET_ID,
        STATE,
        PURCHASE_DATE,
        WARRANTY_DATE,
        LAST_PATCHED,
        LAST_FULL_BACKUP,
        LAST_FULL_IMAGE,
        ORDER_NUMBER,
        COMMENTS,
        LOCATION,
        LOCATION_LOCK,
        BUILDING,
        DEPARTMENT,
        BRANCH_OFFICE,
        BARCODE,
        MANUFACTURER,
        MANUFACTURER_LOCK,
        CONTACT,
        CONTACT_LOCK,
        MODEL,
        MODEL_LOCK,
        HTTP_TITLE,
        HTTP_SERVER,
        HTTPS_SERVER,
        SNMP_OID,
        SMTP_HEADER,
        FTPH_EADER,
        LAST_CHANGED,
        SERIAL_NUMBER,
        SERIAL_NUMBER_LOCK,
        PRINTED_PAGES,
        PRINTER_STATUS,
        CUSTOM_1,
        CUSTOM_2,
        CUSTOM_3,
        CUSTOM_4,
        CUSTOM_5,
        CUSTOM_6,
        CUSTOM_7,
        CUSTOM_8,
        CUSTOM_9,
        CUSTOM_10,
        CUSTOM_11,
        CUSTOM_12,
        CUSTOM_13,
        CUSTOM_14,
        CUSTOM_15,
        CUSTOM_16,
        CUSTOM_17,
        CUSTOM_18,
        CUSTOM_19,
        CUSTOM_20,
        DNS_NAME,
        SSH_SERVER,
        PURCHASE_DATE_LOCK,
        WARRANTY_DATE_LOCK,
        SYSTEM_SKU,
        PREVENT_CLEANUP,
        LOCK_SYSTEM_SKU,
        DMIDECODE_ERROR,
        PRINTED_COLOR_PAGES,
        PRINTED_MONO_PAGES,
        HARDWARE_VERSION,
        SOFTWARE_VERSION,
        FIRMWARE_VERSION,
        DEVICE_VERSION,
        _FILEDATE
    from {{ ref('ODS__LANSWEEPER__TBL_ASSET_CUSTOM') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data