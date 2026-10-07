/************
    Model file generated from TelTool SQL SERVER Ingestion Utility 
    *************/
    

    {{ config(
            materialized='view',
            alias='SUPPL_CHG_REQUEST_PART_INFO',
            transient=false    
) }} 
    
    with source_data as (
        SELECT
        REQUEST_ID, 
 	 	LINE_NBR, 
 	 	TEL_PART_NBR, 
 	 	MODEL_NAME, 
 	 	MANUFACTURER, 
 	 	PRICE, 
 	 	LEAD_TIME, 
 	 	IS_EVALUATION_DATA_PROVIDED, 
 	 	APPLICABLE_DEPARTMENTS, 
 	 	CHANGE_APPROVAL, 
 	 	ALTERNATIVE_PARTS, 
 	 	REMARKS, 
 	 	ROHS_COMPLIANCE, 
 	 	LAST_ORDER_TIMING, 
 	 	QTY, 
 	 	EST_STOCK_AVAILABLE
        FROM {{ ref('COMMON__SUPPLIER__SUPPL_CHG_REQUEST_PART_INFO') }}
        
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