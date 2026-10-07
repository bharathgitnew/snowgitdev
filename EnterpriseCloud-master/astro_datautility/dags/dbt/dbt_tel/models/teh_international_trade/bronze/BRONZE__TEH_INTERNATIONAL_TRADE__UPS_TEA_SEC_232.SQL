/************
    Model file generated from SAPAPIUtility
    *************/


    {{ config(
          materialized='tel_incremental',
          incremental_strategy='insert_overwrite',
          alias='UPS_TEA_SEC_232',
          transient=false
) }}

    with source_data as (
        SELECT
            _FILEDATE
            ,_FILENAME
            ,_UPLOADDATE
            ,get_ignore_case(to_object(JSONFIELD),'Ad Valorem Duty Rate')::STRING AS AD_VALOREM_DUTY_RATE
            ,get_ignore_case(to_object(JSONFIELD),'Broker Office Number')::STRING AS BROKER_OFFICE_NUMBER
            ,get_ignore_case(to_object(JSONFIELD),'Broker Reference Number')::STRING AS BROKER_REFERENCE_NUMBER
            ,get_ignore_case(to_object(JSONFIELD),'Commercial Invoice Detail Line Number')::STRING AS COMMERCIAL_INVOICE_DETAIL_LINE_NUMBER
            ,get_ignore_case(to_object(JSONFIELD),'Commercial Invoice Number')::STRING AS COMMERCIAL_INVOICE_NUMBER
            ,get_ignore_case(to_object(JSONFIELD),'Commercial Invoice Sequence Number')::STRING AS COMMERCIAL_INVOICE_SEQUENCE_NUMBER
            ,get_ignore_case(to_object(JSONFIELD),'Customs Released Date')::STRING AS CUSTOMS_RELEASED_DATE
            ,get_ignore_case(to_object(JSONFIELD),'Duty Amount')::STRING AS DUTY_AMOUNT
            ,get_ignore_case(to_object(JSONFIELD),'Entered Value')::STRING AS ENTERED_VALUE
            ,get_ignore_case(to_object(JSONFIELD),'Entry Date')::STRING AS ENTRY_DATE
            ,get_ignore_case(to_object(JSONFIELD),'Entry Line Number')::STRING AS ENTRY_LINE_NUMBER
            ,get_ignore_case(to_object(JSONFIELD),'Entry Number')::STRING AS ENTRY_NUMBER
            ,get_ignore_case(to_object(JSONFIELD),'Entry Port')::STRING AS ENTRY_PORT
            ,get_ignore_case(to_object(JSONFIELD),'Estimated Liquidation Date')::STRING AS ESTIMATED_LIQUIDATION_DATE
            ,get_ignore_case(to_object(JSONFIELD),'Goods Origin Country or Territory ISO Code')::STRING AS GOODS_ORIGIN_COUNTRY_OR_TERRITORY_ISO_CODE
            ,get_ignore_case(to_object(JSONFIELD),'Harmonized Item Description')::STRING AS HARMONIZED_ITEM_DESCRIPTION
            ,get_ignore_case(to_object(JSONFIELD),'Harmonized Number')::STRING AS HARMONIZED_NUMBER
            ,get_ignore_case(to_object(JSONFIELD),'House Bill Numbers (Concatenated)')::STRING AS HOUSE_BILL_NUMBERS_CONCATENATED
            ,get_ignore_case(to_object(JSONFIELD),'IOR Tax ID')::STRING AS IOR_TAX_ID
            ,get_ignore_case(to_object(JSONFIELD),'Invoice Line Quantity')::STRING AS INVOICE_LINE_QUANTITY
            ,get_ignore_case(to_object(JSONFIELD),'Invoice Line Quantity UOM')::STRING AS INVOICE_LINE_QUANTITY_UOM
            ,get_ignore_case(to_object(JSONFIELD),'Item Number')::STRING AS ITEM_NUMBER
            ,get_ignore_case(to_object(JSONFIELD),'Latest Status')::STRING AS LATEST_STATUS
            ,get_ignore_case(to_object(JSONFIELD),'Latest Status Date')::STRING AS LATEST_STATUS_DATE
            ,get_ignore_case(to_object(JSONFIELD),'Master Bill(s)')::STRING AS MASTER_BILLS
            ,get_ignore_case(to_object(JSONFIELD),'Merchandise Processing Fee')::STRING AS MERCHANDISE_PROCESSING_FEE
            ,get_ignore_case(to_object(JSONFIELD),'POE Actual Arrival Date')::STRING AS POE_ACTUAL_ARRIVAL_DATE
            ,get_ignore_case(to_object(JSONFIELD),'Shipper Name')::STRING AS SHIPPER_NAME
            ,get_ignore_case(to_object(JSONFIELD),'Summary Date')::STRING AS SUMMARY_DATE
            ,get_ignore_case(to_object(JSONFIELD),'Latest Comment')::STRING AS LATEST_COMMENT
            ,get_ignore_case(to_object(JSONFIELD),'Liquidated Date')::STRING AS LIQUIDATED_DATE
            ,TO_DATE(REGEXP_SUBSTR(_FILENAME, '\\d{6}'), 'MMDDYY') AS REPORT_DATE
            ,{{ dbt_utils.generate_surrogate_key([
							'ENTRY_NUMBER',
                            'BROKER_REFERENCE_NUMBER',
                            'BROKER_OFFICE_NUMBER',
                            'LATEST_COMMENT',
                            'MASTER_BILLS',
                            'HOUSE_BILL_NUMBERS_CONCATENATED',
                            'ENTRY_PORT',
                            'POE_ACTUAL_ARRIVAL_DATE',
                            'CUSTOMS_RELEASED_DATE',
                            'ENTRY_LINE_NUMBER',
                            'HARMONIZED_NUMBER',
                            'COMMERCIAL_INVOICE_NUMBER',
                            'COMMERCIAL_INVOICE_DETAIL_LINE_NUMBER',
                            'ITEM_NUMBER',
                            'INVOICE_LINE_QUANTITY',
                            'INVOICE_LINE_QUANTITY_UOM',
                            'ENTERED_VALUE',
                            'AD_VALOREM_DUTY_RATE',
                            'DUTY_AMOUNT',
                            'COMMERCIAL_INVOICE_SEQUENCE_NUMBER',
                            'IOR_TAX_ID',
                            'GOODS_ORIGIN_COUNTRY_OR_TERRITORY_ISO_CODE',
                            'SUMMARY_DATE',
                            'MERCHANDISE_PROCESSING_FEE',
                            'ENTRY_DATE',
                            'HARMONIZED_ITEM_DESCRIPTION',
                            'SHIPPER_NAME',
                            'LATEST_STATUS',
                            'LATEST_STATUS_DATE',
                            'ESTIMATED_LIQUIDATION_DATE',
                            'LIQUIDATED_DATE'
		]) }} as _ROW_SURROGATE_KEY
        FROM {{ source('UPS', 'TEA_SEC_232') }} AS TEA_SEC_232
        WHERE REPORT_DATE = (SELECT MAX(TO_DATE(REGEXP_SUBSTR(_FILENAME, '\\d{6}'), 'MMDDYY')) FROM {{ source('UPS', 'TEA_SEC_232') }} )
        QUALIFY ROW_NUMBER() OVER (PARTITION BY _ROW_SURROGATE_KEY,REPORT_DATE ORDER BY _UPLOADDATE DESC) = 1

),
    transform_data as (
        SELECT
            _FILEDATE AS _FILEDATE,
            _FILENAME AS _FILENAME,
            '{{ invocation_id }}' AS _AUDIT_LOG_ID,
            SHA2('hash_me') AS _ROW_HASH,
            _ROW_SURROGATE_KEY,
            REPORT_DATE,
            ENTRY_NUMBER,
            BROKER_REFERENCE_NUMBER,
            BROKER_OFFICE_NUMBER,
            LATEST_COMMENT,
            MASTER_BILLS,
            HOUSE_BILL_NUMBERS_CONCATENATED,
            ENTRY_PORT,
            POE_ACTUAL_ARRIVAL_DATE,
            CUSTOMS_RELEASED_DATE,
            ENTRY_LINE_NUMBER,
            HARMONIZED_NUMBER,
            COMMERCIAL_INVOICE_NUMBER,
            COMMERCIAL_INVOICE_DETAIL_LINE_NUMBER,
            ITEM_NUMBER,
            TO_NUMBER(REPLACE(INVOICE_LINE_QUANTITY,',',''),38,2) AS INVOICE_LINE_QUANTITY,
            INVOICE_LINE_QUANTITY_UOM,
            TO_NUMBER(REPLACE(ENTERED_VALUE,',',''),38,2) AS ENTERED_VALUE,
            TO_NUMBER(REPLACE(AD_VALOREM_DUTY_RATE,',',''),38,2) AS AD_VALOREM_DUTY_RATE,
            TO_NUMBER(REPLACE(DUTY_AMOUNT,',',''),38,2) AS DUTY_AMOUNT,
            COMMERCIAL_INVOICE_SEQUENCE_NUMBER,
            IOR_TAX_ID,
            GOODS_ORIGIN_COUNTRY_OR_TERRITORY_ISO_CODE,
            SUMMARY_DATE,
            TO_NUMBER(REPLACE(MERCHANDISE_PROCESSING_FEE,',',''),38,2) AS MERCHANDISE_PROCESSING_FEE,
            ENTRY_DATE,
            HARMONIZED_ITEM_DESCRIPTION,
            SHIPPER_NAME,
            LATEST_STATUS,
            LATEST_STATUS_DATE,
            ESTIMATED_LIQUIDATION_DATE,
            LIQUIDATED_DATE
        FROM source_data
    ),
    type_data as (
        SELECT
            _FILEDATE,
            _FILENAME,
            _AUDIT_LOG_ID,
            _ROW_HASH,
            _ROW_SURROGATE_KEY,
            REPORT_DATE,
            ENTRY_NUMBER,
            BROKER_REFERENCE_NUMBER,
            BROKER_OFFICE_NUMBER,
            LATEST_COMMENT,
            MASTER_BILLS,
            HOUSE_BILL_NUMBERS_CONCATENATED,
            ENTRY_PORT,
            coalesce(try_to_timestamp_ntz(POE_ACTUAL_ARRIVAL_DATE, 'MON DD, YYYY HH12:MI:SS AM'), try_to_timestamp_ntz(POE_ACTUAL_ARRIVAL_DATE)) as POE_ACTUAL_ARRIVAL_DATE,
            coalesce(try_to_timestamp_ntz(CUSTOMS_RELEASED_DATE, 'MON DD, YYYY HH12:MI:SS AM'), try_to_timestamp_ntz(CUSTOMS_RELEASED_DATE)) as CUSTOMS_RELEASED_DATE,
            ENTRY_LINE_NUMBER,
            HARMONIZED_NUMBER,
            COMMERCIAL_INVOICE_NUMBER,
            COMMERCIAL_INVOICE_DETAIL_LINE_NUMBER,
            ITEM_NUMBER,
            INVOICE_LINE_QUANTITY,
            INVOICE_LINE_QUANTITY_UOM,
            ENTERED_VALUE,
            AD_VALOREM_DUTY_RATE,
            DUTY_AMOUNT,
            COMMERCIAL_INVOICE_SEQUENCE_NUMBER,
            IOR_TAX_ID,
            GOODS_ORIGIN_COUNTRY_OR_TERRITORY_ISO_CODE,
            coalesce(try_to_timestamp_ntz(SUMMARY_DATE, 'MON DD, YYYY HH12:MI:SS AM'), try_to_timestamp_ntz(SUMMARY_DATE)) as SUMMARY_DATE,
            MERCHANDISE_PROCESSING_FEE,
            coalesce(try_to_timestamp_ntz(ENTRY_DATE, 'MON DD, YYYY HH12:MI:SS AM'), try_to_timestamp_ntz(ENTRY_DATE)) as ENTRY_DATE,
            HARMONIZED_ITEM_DESCRIPTION,
            SHIPPER_NAME,
            LATEST_STATUS,
            coalesce(try_to_timestamp_ntz(LATEST_STATUS_DATE, 'MON DD, YYYY HH12:MI:SS AM'), try_to_timestamp_ntz(LATEST_STATUS_DATE)) as LATEST_STATUS_DATE,
            coalesce(try_to_timestamp_ntz(ESTIMATED_LIQUIDATION_DATE, 'MON DD, YYYY HH12:MI:SS AM'), try_to_timestamp_ntz(ESTIMATED_LIQUIDATION_DATE)) as ESTIMATED_LIQUIDATION_DATE,
            coalesce(try_to_timestamp_ntz(LIQUIDATED_DATE, 'MON DD, YYYY HH12:MI:SS AM'), try_to_timestamp_ntz(LIQUIDATED_DATE)) as LIQUIDATED_DATE,
        FROM transform_data
    )
    SELECT * FROM type_data