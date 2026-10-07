/************
    Model file generated from TelTool SQL SERVER Ingestion Utility 
    *************/
    

    {{ config(
            materialized='view',
            alias='TELCUST_ARF_QRF_DATA',
            transient=false    
) }} 
    
    with source_data as (
        SELECT
        COMPANY, 
 	 	QUOTE_TYPE, 
 	 	ARF_TYPE, 
 	 	REV, 
 	 	REQTYPE, 
 	 	REQUEST_NUMBER, 
 	 	REFERENCE_1, 
 	 	LEAD_TIME_UNIT, 
 	 	LEAD_TIME, 
 	 	QUOTE_CURRENCY, 
 	 	QUOTE_AMT, 
 	 	APPROVER_COMMENT, 
 	 	CONTRACT_NUMBER, 
 	 	EXPIRATION_DATE_REGION, 
 	 	BIS_CUSTOMER_CODE, 
 	 	REQUEST_DATE, 
 	 	PUBLISH_DATE_REGION, 
 	 	REQUEST_REVISION_DATE, 
 	 	REVISE_DATE_REGION, 
 	 	CANCEL_DATE, 
 	 	ON_HOLD_DATE, 
 	 	SAVE_DATE_REGION, 
 	 	APPROVAL_DATE_REGION, 
 	 	SPECIFIC_REQUEST_TYPE, 
 	 	PRODUCT_LINE, 
 	 	MODEL, 
 	 	CUSTOMER_EQUIPMENT_ID, 
 	 	SCANNER_TYPE, 
 	 	DESCRIPTION, 
 	 	FAB, 
 	 	TEL_QUOTE_ID, 
 	 	ARF_TARGET_LEAD_TIME, 
 	 	SHORT_DESC, 
 	 	NODE_TO_OTHER, 
 	 	NODE_FROM_OTHER, 
 	 	PROCESS_TO_OTHER, 
 	 	PROCESS_FROM_OTHER, 
 	 	NODE_OTHER, 
 	 	PROCESS_OTHER, 
 	 	NODES, 
 	 	FABS, 
 	 	PROCESSES, 
 	 	TO_NODES, 
 	 	TO_PROCESSES, 
 	 	FROM_PROCESSES, 
 	 	FROM_NODES, 
 	 	REQUESTOR, 
 	 	REQUEST_REVISION_NAME, 
 	 	CANCEL_NAME, 
 	 	ON_HOLD_NAME, 
 	 	REVISE_NAME, 
 	 	PUBLISH_NAME, 
 	 	APPROVAL_NAME, 
 	 	STATUS, 
 	 	STATUS_DATE, 
 	 	PRIORITY_FLAG, 
 	 	FEASIBLE, 
 	 	TEL_COMMENT, 
 	 	CATEGORY, 
 	 	NTE, 
 	 	TEL_QUOTE_TYPE, 
 	 	ENTITY, 
 	 	ESA, 
 	 	TIERED, 
 	 	TEL_QUOTE_NODE_PROCESS, 
 	 	RELEASE_FROM_HOLD_DATE, 
 	 	REVERTED_DATE, 
 	 	ACTIVE, 
 	 	TEL_QUOTE_STATUS, 
 	 	THRESHOLD_TIER, 
 	 	THRESHOLD_COUNT, 
 	 	THRESHOLD_DURATION, 
 	 	THRESHOLD_SITE, 
 	 	THRESHOLD_OTHER, 
 	 	ESA_LITE_CANDIDATE, 
 	 	ESA_LITE_YEAR, 
 	 	ESA_LITE_QUARTER, 
 	 	ESA_LITE_COMMENTS, 
 	 	EQUIPMENT_QUOTE_TEL_QUOTE_ID
        FROM {{ ref('ODS__TELCUSTOMER__TELCUST_ARF_QRF_DATA') }}
        
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