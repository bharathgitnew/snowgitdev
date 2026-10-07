   
    {{ config(
          materialized='tel_incremental',
          incremental_strategy='merge',
          alias='GMX_INVOICE_EXPORT_HISTORY',
	      unique_key = ['SEQ_ID','SEQ_ITEM_ID'],
          transient=false    
) }} 
    
    with source_data as (
        SELECT
            JSONFIELD:"SeqID"::STRING AS SEQ_ID,
            JSONFIELD:"SeqItemID"::STRING AS SEQ_ITEM_ID,
            JSONFIELD:"CustomerPoNo_SOHeader"::STRING as CUSTOMER_PO_NO_SO_HEADER,
            JSONFIELD:"CustomerPoNo_SOItem"::STRING as CUSTOMER_PO_NO_SO_ITEM,
            JSONFIELD:"CustomerPoNo_InvoiceExportHistory"::STRING AS CUSTOMER_PO_NO_INVOICE_EXPORT_HISTORY,
            JSONFIELD:"ActualQtyDeliveredInSalesUnits"::STRING AS ACTUAL_QUANTITY_DELIVERED_IN_SALES_UNITS,
            JSONFIELD:"MaterialCode"::STRING AS MATERIAL_CODE,
            JSONFIELD:"MAWB"::STRING AS MAWB,
            JSONFIELD:"HAWB"::STRING AS HAWB,
            JSONFIELD:"TrackingNo"::STRING AS TRACKING_NUMBER,
            _FILEDATE,
            _FILENAME,
            _UPLOADDATE
        FROM {{ source('SAPH', 'SAP_US_SDT_EV_INVOICEEXPORTHISTORY_GMX') }}
        WHERE JSONFIELD:"ShipToPartyCountry"::STRING = 'US'
	{% if is_tel_incremental() %} AND  _FILENAME >= IFNULL((SELECT MAX(_FILENAME) FROM {{ this }}),'1970-01-01'){% endif %}
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:"SeqID"::STRING,JSONFIELD:"SeqItemID"::STRING  ORDER BY _FILEDATE DESC )) = 1
	
    ),
    transform_data as (
        SELECT
            '{{ invocation_id }}' AS _AUDIT_LOG_ID,
            SHA2('hash_me') as _ROW_HASH,
            _FILEDATE,
            _FILENAME,
            _UPLOADDATE,
            SEQ_ID,
            SEQ_ITEM_ID,
            CUSTOMER_PO_NO_SO_HEADER,
            CUSTOMER_PO_NO_SO_ITEM,
            CUSTOMER_PO_NO_INVOICE_EXPORT_HISTORY,
            ACTUAL_QUANTITY_DELIVERED_IN_SALES_UNITS,
            MATERIAL_CODE,
            MAWB,
            HAWB,
            TRACKING_NUMBER            	
        FROM source_data
    ),
    type_data as (
        SELECT
            cast(_AUDIT_LOG_ID AS varchar(128)) AS _AUDIT_LOG_ID,
            cast(_ROW_HASH AS varchar(128)) AS _ROW_HASH,
            CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
            CAST(_FILENAME AS varchar(128)) AS _FILENAME,
            CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
            SEQ_ID,
            SEQ_ITEM_ID,
            CUSTOMER_PO_NO_SO_HEADER,
            CUSTOMER_PO_NO_SO_ITEM,
            CUSTOMER_PO_NO_INVOICE_EXPORT_HISTORY,
            CAST(ACTUAL_QUANTITY_DELIVERED_IN_SALES_UNITS AS NUMBER(38,3)) AS ACTUAL_QUANTITY_DELIVERED_IN_SALES_UNITS,
            MATERIAL_CODE,
            MAWB,
            HAWB,
            TRACKING_NUMBER
        FROM transform_data
    )
    SELECT * FROM type_data