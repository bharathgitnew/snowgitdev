/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Lansweeper\TBL_ASSET_CUSTOM__Lansweeper_tblAssetCustom.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\lansweeper\TBL_ASSET_CUSTOM.SQL 
-materialized incremental
-alias TBL_ASSET_CUSTOM 
-incremental_strategy insert_overwrite
-envVariable <<LZ>> 
-sourceSchema LANSWEEPER
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/12/2022 9:15:49 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='TBL_ASSET_CUSTOM',
    unique_key = []
) }}


with source_data as 
(
    SELECT 
        _FILENAME 
        ,_FILEDATE 
        ,JSONFIELD:"CustID"::NUMBER AS Cust_ID 
        ,JSONFIELD:"AssetID"::NUMBER AS Asset_ID 
        ,JSONFIELD:"State"::NUMBER AS State 
        ,REGEXP_REPLACE(JSONFIELD:"PurchaseDate", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Purchase_Date 
        ,REGEXP_REPLACE(JSONFIELD:"Warrantydate", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Warranty_date 
        ,REGEXP_REPLACE(JSONFIELD:"LastPatched", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Last_Patched 
        ,REGEXP_REPLACE(JSONFIELD:"LastFullBackup", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Last_Full_Backup 
        ,REGEXP_REPLACE(JSONFIELD:"LastFullimage", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Last_Full_image 
        ,JSONFIELD:"OrderNumber"::STRING AS Order_Number 
        ,JSONFIELD:"Comments"::STRING AS Comments 
        ,JSONFIELD:"Location"::STRING AS Location 
        ,JSONFIELD:"LocationLock"::NUMBER AS Location_Lock 
        ,JSONFIELD:"Building"::STRING AS Building 
        ,JSONFIELD:"Department"::STRING AS Department 
        ,JSONFIELD:"Branchoffice"::STRING AS Branch_office 
        ,JSONFIELD:"BarCode"::STRING AS BarCode 
        ,JSONFIELD:"Manufacturer"::STRING AS Manufacturer 
        ,JSONFIELD:"ManufacturerLock"::NUMBER AS Manufacturer_Lock 
        ,JSONFIELD:"Contact"::STRING AS Contact 
        ,JSONFIELD:"ContactLock"::NUMBER AS Contact_Lock 
        ,JSONFIELD:"Model"::STRING AS Model 
        ,JSONFIELD:"ModelLock"::NUMBER AS Model_Lock 
        ,JSONFIELD:"HTTPTitle"::STRING AS HTTP_Title 
        ,JSONFIELD:"HttpServer"::STRING AS Http_Server 
        ,JSONFIELD:"HttpsServer"::STRING AS Https_Server 
        ,JSONFIELD:"SnmpOID"::STRING AS Snmp_OID 
        ,JSONFIELD:"SMTPheader"::STRING AS SMTP_header 
        ,JSONFIELD:"FTPheader"::STRING AS FTPh_eader 
        ,REGEXP_REPLACE(JSONFIELD:"Lastchanged", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Last_changed 
        ,JSONFIELD:"Serialnumber"::STRING AS Serial_number 
        ,JSONFIELD:"SerialnumberLock"::NUMBER AS Serial_number_Lock 
        ,JSONFIELD:"Printedpages"::NUMBER AS Printed_pages 
        ,JSONFIELD:"Printerstatus"::STRING AS Printer_status 
        ,JSONFIELD:"Custom1"::STRING AS Custom_1 
        ,JSONFIELD:"Custom2"::STRING AS Custom_2 
        ,JSONFIELD:"Custom3"::STRING AS Custom_3 
        ,JSONFIELD:"Custom4"::STRING AS Custom_4 
        ,JSONFIELD:"Custom5"::STRING AS Custom_5 
        ,JSONFIELD:"Custom6"::STRING AS Custom_6 
        ,JSONFIELD:"Custom7"::STRING AS Custom_7 
        ,JSONFIELD:"Custom8"::STRING AS Custom_8 
        ,JSONFIELD:"Custom9"::STRING AS Custom_9 
        ,JSONFIELD:"Custom10"::STRING AS Custom_10 
        ,JSONFIELD:"Custom11"::STRING AS Custom_11 
        ,JSONFIELD:"Custom12"::STRING AS Custom_12 
        ,JSONFIELD:"Custom13"::STRING AS Custom_13 
        ,JSONFIELD:"Custom14"::STRING AS Custom_14 
        ,JSONFIELD:"Custom15"::STRING AS Custom_15 
        ,JSONFIELD:"Custom16"::STRING AS Custom_16 
        ,JSONFIELD:"Custom17"::STRING AS Custom_17 
        ,JSONFIELD:"Custom18"::STRING AS Custom_18 
        ,JSONFIELD:"Custom19"::STRING AS Custom_19 
        ,JSONFIELD:"Custom20"::STRING AS Custom_20 
        ,JSONFIELD:"DNSName"::STRING AS DNS_Name 
        ,JSONFIELD:"SSHServer"::STRING AS SSH_Server 
        ,JSONFIELD:"PurchaseDateLock"::NUMBER AS Purchase_Date_Lock 
        ,JSONFIELD:"WarrantyDateLock"::NUMBER AS Warranty_Date_Lock 
        ,JSONFIELD:"SystemSKU"::STRING AS System_SKU 
        ,JSONFIELD:"PreventCleanup"::NUMBER AS Prevent_Cleanup 
        ,JSONFIELD:"LockSystemSKU"::NUMBER AS Lock_System_SKU 
        ,JSONFIELD:"DmidecodeError"::NUMBER AS Dmidecode_Error 
        ,JSONFIELD:"PrintedColorPages"::NUMBER AS Printed_Color_Pages 
        ,JSONFIELD:"PrintedMonoPages"::NUMBER AS Printed_Mono_Pages 
        ,JSONFIELD:"HardwareVersion"::STRING AS Hardware_Version 
        ,JSONFIELD:"SoftwareVersion"::STRING AS Software_Version 
        ,JSONFIELD:"FirmwareVersion"::STRING AS Firmware_Version 
        ,JSONFIELD:"DeviceVersion"::STRING AS Device_Version 
        FROM {{ source("LANSWEEPER", "TBLASSETCUSTOM") }} 
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("LANSWEEPER", "TBLASSETCUSTOM") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.ASSET_ID, 
        source_data.BARCODE, 
        source_data.BRANCH_OFFICE, 
        source_data.BUILDING, 
        source_data.COMMENTS, 
        source_data.CONTACT, 
        source_data.CONTACT_LOCK, 
        source_data.CUSTOM_1, 
        source_data.CUSTOM_10, 
        source_data.CUSTOM_11, 
        source_data.CUSTOM_12, 
        source_data.CUSTOM_13, 
        source_data.CUSTOM_14, 
        source_data.CUSTOM_15, 
        source_data.CUSTOM_16, 
        source_data.CUSTOM_17, 
        source_data.CUSTOM_18, 
        source_data.CUSTOM_19, 
        source_data.CUSTOM_2, 
        source_data.CUSTOM_20, 
        source_data.CUSTOM_3, 
        source_data.CUSTOM_4, 
        source_data.CUSTOM_5, 
        source_data.CUSTOM_6, 
        source_data.CUSTOM_7, 
        source_data.CUSTOM_8, 
        source_data.CUSTOM_9, 
        source_data.CUST_ID, 
        source_data.DEPARTMENT, 
        source_data.DEVICE_VERSION, 
        source_data.DMIDECODE_ERROR, 
        source_data.DNS_NAME, 
        source_data.FIRMWARE_VERSION, 
        source_data.FTPH_EADER, 
        source_data.HARDWARE_VERSION, 
        source_data.HTTPS_SERVER, 
        source_data.HTTP_SERVER, 
        source_data.HTTP_TITLE, 
        source_data.LAST_CHANGED, 
        source_data.LAST_FULL_BACKUP, 
        source_data.LAST_FULL_IMAGE, 
        source_data.LAST_PATCHED, 
        source_data.LOCATION, 
        source_data.LOCATION_LOCK, 
        source_data.LOCK_SYSTEM_SKU, 
        source_data.MANUFACTURER, 
        source_data.MANUFACTURER_LOCK, 
        source_data.MODEL, 
        source_data.MODEL_LOCK, 
        source_data.ORDER_NUMBER, 
        source_data.PREVENT_CLEANUP, 
        source_data.PRINTED_COLOR_PAGES, 
        source_data.PRINTED_MONO_PAGES, 
        source_data.PRINTED_PAGES, 
        source_data.PRINTER_STATUS, 
        source_data.PURCHASE_DATE, 
        source_data.PURCHASE_DATE_LOCK, 
        source_data.SERIAL_NUMBER, 
        source_data.SERIAL_NUMBER_LOCK, 
        source_data.SMTP_HEADER, 
        source_data.SNMP_OID, 
        source_data.SOFTWARE_VERSION, 
        source_data.SSH_SERVER, 
        source_data.STATE, 
        source_data.SYSTEM_SKU, 
        source_data.WARRANTY_DATE, 
        source_data.WARRANTY_DATE_LOCK, 
        source_data._FILEDATE 
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID 
        FROM source_data
        )
,type_data as 
(
    select
        cast(CUST_ID as NUMBER(38,0)) as CUST_ID,
        cast(ASSET_ID as NUMBER(38,0)) as ASSET_ID,
        cast(STATE as NUMBER(38,0)) as STATE,
        cast(PURCHASE_DATE as TIMESTAMP_NTZ(9)) as PURCHASE_DATE,
        cast(WARRANTY_DATE as TIMESTAMP_NTZ(9)) as WARRANTY_DATE,
        cast(LAST_PATCHED as TIMESTAMP_NTZ(9)) as LAST_PATCHED,
        cast(LAST_FULL_BACKUP as TIMESTAMP_NTZ(9)) as LAST_FULL_BACKUP,
        cast(LAST_FULL_IMAGE as TIMESTAMP_NTZ(9)) as LAST_FULL_IMAGE,
        cast(ORDER_NUMBER as VARCHAR(16777216)) as ORDER_NUMBER,
        cast(COMMENTS as VARCHAR(16777216)) as COMMENTS,
        cast(LOCATION as VARCHAR(16777216)) as LOCATION,
        cast(LOCATION_LOCK as NUMBER(38,0)) as LOCATION_LOCK,
        cast(BUILDING as VARCHAR(16777216)) as BUILDING,
        cast(DEPARTMENT as VARCHAR(16777216)) as DEPARTMENT,
        cast(BRANCH_OFFICE as VARCHAR(16777216)) as BRANCH_OFFICE,
        cast(BARCODE as VARCHAR(16777216)) as BARCODE,
        cast(MANUFACTURER as VARCHAR(16777216)) as MANUFACTURER,
        cast(MANUFACTURER_LOCK as NUMBER(38,0)) as MANUFACTURER_LOCK,
        cast(CONTACT as VARCHAR(16777216)) as CONTACT,
        cast(CONTACT_LOCK as NUMBER(38,0)) as CONTACT_LOCK,
        cast(MODEL as VARCHAR(16777216)) as MODEL,
        cast(MODEL_LOCK as NUMBER(38,0)) as MODEL_LOCK,
        cast(HTTP_TITLE as VARCHAR(16777216)) as HTTP_TITLE,
        cast(HTTP_SERVER as VARCHAR(16777216)) as HTTP_SERVER,
        cast(HTTPS_SERVER as VARCHAR(16777216)) as HTTPS_SERVER,
        cast(SNMP_OID as VARCHAR(16777216)) as SNMP_OID,
        cast(SMTP_HEADER as VARCHAR(16777216)) as SMTP_HEADER,
        cast(FTPH_EADER as VARCHAR(16777216)) as FTPH_EADER,
        cast(LAST_CHANGED as TIMESTAMP_NTZ(9)) as LAST_CHANGED,
        cast(SERIAL_NUMBER as VARCHAR(16777216)) as SERIAL_NUMBER,
        cast(SERIAL_NUMBER_LOCK as NUMBER(38,0)) as SERIAL_NUMBER_LOCK,
        cast(PRINTED_PAGES as NUMBER(38,0)) as PRINTED_PAGES,
        cast(PRINTER_STATUS as VARCHAR(16777216)) as PRINTER_STATUS,
        cast(CUSTOM_1 as VARCHAR(16777216)) as CUSTOM_1,
        cast(CUSTOM_2 as VARCHAR(16777216)) as CUSTOM_2,
        cast(CUSTOM_3 as VARCHAR(16777216)) as CUSTOM_3,
        cast(CUSTOM_4 as VARCHAR(16777216)) as CUSTOM_4,
        cast(CUSTOM_5 as VARCHAR(16777216)) as CUSTOM_5,
        cast(CUSTOM_6 as VARCHAR(16777216)) as CUSTOM_6,
        cast(CUSTOM_7 as VARCHAR(16777216)) as CUSTOM_7,
        cast(CUSTOM_8 as VARCHAR(16777216)) as CUSTOM_8,
        cast(CUSTOM_9 as VARCHAR(16777216)) as CUSTOM_9,
        cast(CUSTOM_10 as VARCHAR(16777216)) as CUSTOM_10,
        cast(CUSTOM_11 as VARCHAR(16777216)) as CUSTOM_11,
        cast(CUSTOM_12 as VARCHAR(16777216)) as CUSTOM_12,
        cast(CUSTOM_13 as VARCHAR(16777216)) as CUSTOM_13,
        cast(CUSTOM_14 as VARCHAR(16777216)) as CUSTOM_14,
        cast(CUSTOM_15 as VARCHAR(16777216)) as CUSTOM_15,
        cast(CUSTOM_16 as VARCHAR(16777216)) as CUSTOM_16,
        cast(CUSTOM_17 as VARCHAR(16777216)) as CUSTOM_17,
        cast(CUSTOM_18 as VARCHAR(16777216)) as CUSTOM_18,
        cast(CUSTOM_19 as VARCHAR(16777216)) as CUSTOM_19,
        cast(CUSTOM_20 as VARCHAR(16777216)) as CUSTOM_20,
        cast(DNS_NAME as VARCHAR(16777216)) as DNS_NAME,
        cast(SSH_SERVER as VARCHAR(16777216)) as SSH_SERVER,
        cast(PURCHASE_DATE_LOCK as NUMBER(38,0)) as PURCHASE_DATE_LOCK,
        cast(WARRANTY_DATE_LOCK as NUMBER(38,0)) as WARRANTY_DATE_LOCK,
        cast(SYSTEM_SKU as VARCHAR(16777216)) as SYSTEM_SKU,
        cast(PREVENT_CLEANUP as NUMBER(38,0)) as PREVENT_CLEANUP,
        cast(LOCK_SYSTEM_SKU as NUMBER(38,0)) as LOCK_SYSTEM_SKU,
        cast(DMIDECODE_ERROR as NUMBER(38,0)) as DMIDECODE_ERROR,
        cast(PRINTED_COLOR_PAGES as NUMBER(38,0)) as PRINTED_COLOR_PAGES,
        cast(PRINTED_MONO_PAGES as NUMBER(38,0)) as PRINTED_MONO_PAGES,
        cast(HARDWARE_VERSION as VARCHAR(16777216)) as HARDWARE_VERSION,
        cast(SOFTWARE_VERSION as VARCHAR(16777216)) as SOFTWARE_VERSION,
        cast(FIRMWARE_VERSION as VARCHAR(16777216)) as FIRMWARE_VERSION,
        cast(DEVICE_VERSION as VARCHAR(16777216)) as DEVICE_VERSION,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data