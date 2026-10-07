{{ config(
    materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
    alias='TEL_SALES_CRM_ACCOUNT_FORECAST_REVENUE_BOOKING_STACKED',
    transient=false
) }}

WITH
SOURCE_DATA AS (

select 
    'Revenue'                                   as Report_Type,
    OPPORTUNITY_ID,
	SALES_DOCUMENT_ITEM_NO,
	PROJECT_NO,
	SALES_ORDER_NO,
	CUSTOMER_FORECAST_ID,
    case when not SALES_ACCOUNT ilike 'Intel' then ACCOUNT_REVENUE_FORECAST_FLAG
        else BU_REVENUE_FORECAST_FLAG
    end                                         as Account_Forecast,
    case when not SALES_ACCOUNT ilike 'Intel' then ACCOUNT_REVENUE_FY
        else CORPORATE_BU_REVENUE_FY							
    end                                         as Account_Forecast_FY,
	case when not SALES_ACCOUNT ilike 'Intel' then ACCOUNT_REVENUE_FY_HALF
        else CORPORATE_BU_REVENUE_FY_HALF				
    end                                         as Account_Forecast_FY_Half,
	case when not SALES_ACCOUNT ilike 'Intel' then ACCOUNT_REVENUE_FY_Q
        else CORPORATE_BU_REVENUE_FY_Q					
    end                                         as Account_Forecast_FY_Q,
	SALES_ACCOUNT,
    SALES_REGION,
	END_USER,
	FAB,
	BU,
	BU_GROUP,
	BU_TYPE,
	SUB_BU,
    SALES_CATEGORY_GROUP,
	SALES_CATEGORY,
	case when not SALES_ACCOUNT ilike 'Intel' then ADJUSTED_CONFIDENCE_ACCOUNT_SHORT
        else CONFIDENCE_BU_SHORT			
    end                                         as CONFIDENCE,
	ORDER_ITEM_OPPORTUNITY                      as Product_Name,
    ORDER_ITEM_SALES_DOCUMENT                   as SD_Order_Item,
    ADJUSTED_SERIAL_NO							as SERIAL_NO,
	CUSTOMER_TOOL_ID,
    QUOTE_NO,
	PURCHASE_ORDER_NO							as PO_No,
	case when not SALES_ACCOUNT ilike 'Intel' then ADJUSTED_BOOKING_DATE_ACCOUNT				
        else END_USER_BOOKING_DATE_BU
    end                                         as Booking_Date,
    PO_RECEIPT_DATE,
    ACTUAL_BOOKING_DATE,
	IS_BOOKING_ACTUAL,
	SHIP_DATE,
    ADJUSTED_SHIP_DATE,
	case when not SALES_ACCOUNT ilike 'Intel' then ADJUSTED_END_USER_SALES_DATE_ACCOUNT
        else END_USER_SALES_DATE_BU
    end                                         as SALES_DATE,
	REVENUE_RECOGNITION_STATUS,
    QUANTITY,
	END_USER_SALES_AMOUNT_JPY					as AMOUNT,
  	REVENUE_RECOGNITION_CRITERIA_SHORT          as REVENUE_RECOGNITION_CRITERIA,
    case when not SALES_ACCOUNT ilike 'Intel' then ACCOUNT_REVENUE_FORECAST_FK_DATE
        else CORPORATE_BU_REVENUE_FORECAST_FK_DATE
    end                                         as ACCOUNT_FORECAST_FK_DATE,
    DATA_SNAPSHOT,
	DATA_SNAPSHOT_TIMESTAMP,
    END_USER_CODE
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_SALES_DOCUMENTS') }}
where case when not SALES_ACCOUNT ilike 'Intel' then ACCOUNT_REVENUE_FORECAST_FK_DATE
        else CORPORATE_BU_REVENUE_FORECAST_FK_DATE
      end 
        >= BEGINNING_OF_PREVIOUS_FY
	and case when not SALES_ACCOUNT ilike 'Intel' then ACCOUNT_REVENUE_FORECAST_FK_DATE
            else CORPORATE_BU_REVENUE_FORECAST_FK_DATE
        end
        <= END_OF_NEXT_FY
    and case when not SALES_ACCOUNT ilike 'Intel' then ACCOUNT_REVENUE_FORECAST_FLAG
            else BU_REVENUE_FORECAST_FLAG
        end
        = 'Yes' 

union all
select
	'Booking'                           as Report_Type,
    OPPORTUNITY_ID,
    ''                                  as Sales_Document_Item_No,
	PROJECT_NO,
	SALES_ORDER_NO,
	CUSTOMER_FORECAST_ID,
    case when not SALES_ACCOUNT ilike 'Intel' then ACCOUNT_BOOKING_FORECAST_FLAG				
        else BU_BOOKING_FORECAST_FLAG
    end                                 as Account_Forecast,
    case when not SALES_ACCOUNT ilike 'Intel' then ACCOUNT_BOOKING_FY				
        else CORPORATE_BU_BOOKING_FY
    end                                 as Account_Forecast_FY,
    case when not SALES_ACCOUNT ilike 'Intel' then ACCOUNT_BOOKING_FY_HALF				
        else CORPORATE_BU_BOOKING_FY_HALF
    end                                 as Account_Forecast_FY_Half,
    case when not SALES_ACCOUNT ilike 'Intel' then ACCOUNT_BOOKING_FY_Q			
        else CORPORATE_BU_BOOKING_FY_Q
    end                                 as Account_Forecast_FY_Q,
	SALES_ACCOUNT,
	SALES_REGION,
	END_USER,
	FAB,
	BU,
	BU_GROUP,
	BU_TYPE,
	SUB_BU,
	SALES_CATEGORY_GROUP,
	SALES_CATEGORY,
    case when not SALES_ACCOUNT ilike 'Intel' then ADJUSTED_CONFIDENCE_ACCOUNT_SHORT				
        else CONFIDENCE_BU_SHORT
    end                                 as CONFIDENCE,
    ORDER_ITEM                          as Product_Name,
	''                                  as SD_Order_Item,
	ADJUSTED_SERIAL_NO					as SERIAL_No,
	CUSTOMER_TOOL_ID,
    QUOTE_NO,
	PURCHASE_ORDER_NO					as PO_No,
    case when not SALES_ACCOUNT ilike 'Intel' then ADJUSTED_BOOKING_DATE_ACCOUNT				
        else END_USER_BOOKING_DATE_BU
    end                                 as Booking_Date,
	PO_RECEIPT_DATE,
	ACTUAL_BOOKING_DATE,
    IS_BOOKING_ACTUAL,
	SHIP_DATE,
    null                                as Adjusted_Ship_Date,
    null                                as Sales_Date,
    ''                                  as Revenue_Recognition_Status,
	QUANTITY,
    END_USER_BOOKING_AMOUNT_JPY         as AMOUNT,
    ''                                  as Revenue_Recognition_Criteria,
    case when not SALES_ACCOUNT ilike 'Intel' then ACCOUNT_BOOKING_FORECAST_FK_DATE
        else CORPORATE_BU_BOOKING_FORECAST_FK_DATE
    end                                 as Account_Forecast_FK_Date,
    DATA_SNAPSHOT,
	DATA_SNAPSHOT_TIMESTAMP,
    END_USER_CODE
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_OPPORTUNITIES') }}
where case when not SALES_ACCOUNT ilike 'Intel' then ACCOUNT_BOOKING_FORECAST_FK_DATE
        else CORPORATE_BU_BOOKING_FORECAST_FK_DATE
      end
      >= BEGINNING_OF_PREVIOUS_FY
	and case when not SALES_ACCOUNT ilike 'Intel' then ACCOUNT_BOOKING_FORECAST_FK_DATE
            else CORPORATE_BU_BOOKING_FORECAST_FK_DATE
        end
        <= END_OF_NEXT_FY
    and case when not SALES_ACCOUNT ilike 'Intel' then ACCOUNT_BOOKING_FORECAST_FLAG				
            else BU_BOOKING_FORECAST_FLAG
        end
        = 'Yes'
),
TRANSFORM_DATA AS (
SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        REPORT_TYPE,
        OPPORTUNITY_ID,
        SALES_DOCUMENT_ITEM_NO,
        PROJECT_NO,
        SALES_ORDER_NO,
        CUSTOMER_FORECAST_ID,
        ACCOUNT_FORECAST,
        ACCOUNT_FORECAST_FY,
        ACCOUNT_FORECAST_FY_HALF,
        ACCOUNT_FORECAST_FY_Q,
        SALES_ACCOUNT,
        SALES_REGION,
        END_USER,
        FAB,
        BU,
        BU_GROUP,
        BU_TYPE,
        SUB_BU,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        CONFIDENCE,
        PRODUCT_NAME,
        SD_ORDER_ITEM,
        SERIAL_NO,
        CUSTOMER_TOOL_ID,
        QUOTE_NO,
        PO_NO,
        BOOKING_DATE,
        PO_RECEIPT_DATE,
        ACTUAL_BOOKING_DATE,
        IS_BOOKING_ACTUAL,
        SHIP_DATE,
        ADJUSTED_SHIP_DATE,
        SALES_DATE,
        REVENUE_RECOGNITION_STATUS,
        QUANTITY,
        AMOUNT,
        REVENUE_RECOGNITION_CRITERIA,
        ACCOUNT_FORECAST_FK_DATE,
        DATA_SNAPSHOT,
        DATA_SNAPSHOT_TIMESTAMP,
        END_USER_CODE
FROM SOURCE_DATA

)

,
TYPE_DATA AS (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        REPORT_TYPE,
        OPPORTUNITY_ID,
        SALES_DOCUMENT_ITEM_NO,
        PROJECT_NO,
        SALES_ORDER_NO,
        CUSTOMER_FORECAST_ID,
        ACCOUNT_FORECAST,
        ACCOUNT_FORECAST_FY,
        ACCOUNT_FORECAST_FY_HALF,
        ACCOUNT_FORECAST_FY_Q,
        SALES_ACCOUNT,
        SALES_REGION,
        END_USER,
        FAB,
        BU,
        BU_GROUP,
        BU_TYPE,
        SUB_BU,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        CONFIDENCE,
        PRODUCT_NAME,
        SD_ORDER_ITEM,
        SERIAL_NO,
        CUSTOMER_TOOL_ID,
        QUOTE_NO,
        PO_NO,
        CAST(BOOKING_DATE as DATE) as BOOKING_DATE,
        CAST(PO_RECEIPT_DATE as DATE) as PO_RECEIPT_DATE,
        CAST(ACTUAL_BOOKING_DATE as DATE) as ACTUAL_BOOKING_DATE,
        IS_BOOKING_ACTUAL,
        CAST(SHIP_DATE as DATE) as SHIP_DATE,
        CAST(ADJUSTED_SHIP_DATE as DATE) as ADJUSTED_SHIP_DATE,
        CAST(SALES_DATE as DATE) as SALES_DATE,
        REVENUE_RECOGNITION_STATUS,
        CAST(QUANTITY as NUMBER(38,0)) as QUANTITY,
        CAST(AMOUNT as NUMBER(38,0)) as AMOUNT,
        REVENUE_RECOGNITION_CRITERIA,
        CAST(ACCOUNT_FORECAST_FK_DATE as DATE) as ACCOUNT_FORECAST_FK_DATE,
        CAST(DATA_SNAPSHOT as DATE) as DATA_SNAPSHOT,
        CAST(DATA_SNAPSHOT_TIMESTAMP as TIMESTAMP_NTZ(9)) as DATA_SNAPSHOT_TIMESTAMP,
        END_USER_CODE
from transform_data
)
SELECT * FROM TYPE_DATA