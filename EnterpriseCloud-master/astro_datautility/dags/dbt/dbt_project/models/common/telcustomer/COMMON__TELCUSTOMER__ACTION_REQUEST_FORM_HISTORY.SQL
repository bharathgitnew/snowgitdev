{{ config(
       materialized='incremental'  ,
    incremental_strategy='insert_overwrite'  ,
    alias='Action_Request_Form_History'  
) }}

with source_data as
(
	select
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
		ACTIVE
	from {{ ref('ODS__TELCUSTOMER__TELCUST_ARF_QRF_DATA') }}
	where ReqType = 'ARF'
)
,transform_data AS
(
	select
		'{{ invocation_id }}'											AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		 Request_Number													AS Request_Number
		,LPAD( Rev , 2, '0')											AS Action_Request_Revision_Number
		,TO_VARCHAR(Request_Number) || '-' || LPAD( Rev , 2, '0') 		AS Arf_Request_Status_Key
		,CASE
		    WHEN Rev  = 0 THEN TO_DATE( Request_Date )
			ELSE TO_DATE( Publish_Date_Region )
		 END 															AS Arf_Intel_Request_Date
		,TO_DATE(Publish_Date_Region)									AS Arf_Tel_Publish_Date
		,TO_DATE(Approval_Date_Region)									AS Arf_Intel_Approval_Date
		,TO_DATE(Status_Date)											AS Arf_Status_Date
		,TO_DATE(Cancel_Date)											AS Arf_Cancel_Date
		,DATEDIFF(DAY, Request_Date, Publish_Date_Region )				AS Arf_Tel_Publish_Days
		,DATEDIFF(DAY, Publish_Date_Region, Approval_Date_Region )		AS Arf_Intel_Approval_Days
		,UPPER(Requestor)												AS Requestor
		,UPPER(Status)													AS Request_Status
		,UPPER(Priority_Flag) 											AS Arf_Priority
		,UPPER(Arf_Type)												AS Arf_Type
		,Product_Line													AS Business_Unit
		,UPPER(Fab)														AS Site
		,UPPER(Category)												AS Category
		,UPPER(Model)													AS Model
		,Nodes															AS Process
		,UPPER(Reference_1)										 		AS Tel_Description
		,UPPER(Description)												AS Intel_Description
		,Tel_Quote_Node_Process											AS Tel_Quote_Node_Process
		,UPPER(Specific_Request_Type)									AS Specific_Request_Type
		,UPPER(Company)													AS Client
		,Bis_Customer_Code												AS Client_Code
		,REQUEST_REVISION_DATE											AS ARF_REVISION_DATE
		,RELEASE_FROM_HOLD_DATE											AS RELEASE_FROM_HOLD_DATE
		,REQUEST_REVISION_NAME											AS ARF_REVISION_NAME
		,APPROVER_COMMENT												AS APPROVER_COMMENT
		,TEL_COMMENT													AS TEL_COMMENT
	from source_data
)
,type_data as 
(
    select
		cast(_AUDIT_LOG_ID as VARCHAR(16777216)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as VARCHAR(16777216)) as _ROW_HASH,		
        cast(REQUEST_NUMBER as NUMBER(38,0)) as REQUEST_NUMBER,
        cast(ACTION_REQUEST_REVISION_NUMBER as VARCHAR(16777216)) as ACTION_REQUEST_REVISION_NUMBER,
        cast(ARF_REQUEST_STATUS_KEY as VARCHAR(16777216)) as ARF_REQUEST_STATUS_KEY,
        cast(ARF_INTEL_REQUEST_DATE as DATE) as ARF_INTEL_REQUEST_DATE,
        cast(ARF_TEL_PUBLISH_DATE as DATE) as ARF_TEL_PUBLISH_DATE,
        cast(ARF_INTEL_APPROVAL_DATE as DATE) as ARF_INTEL_APPROVAL_DATE,
        cast(ARF_STATUS_DATE as DATE) as ARF_STATUS_DATE,
        cast(ARF_CANCEL_DATE as DATE) as ARF_CANCEL_DATE,
        cast(ARF_TEL_PUBLISH_DAYS as NUMBER(9,0)) as ARF_TEL_PUBLISH_DAYS,
        cast(ARF_INTEL_APPROVAL_DAYS as NUMBER(9,0)) as ARF_INTEL_APPROVAL_DAYS,
        cast(REQUESTOR as VARCHAR(16777216)) as REQUESTOR,
        cast(REQUEST_STATUS as VARCHAR(16777216)) as REQUEST_STATUS,
        cast(ARF_PRIORITY as VARCHAR(16777216)) as ARF_PRIORITY,
        cast(ARF_TYPE as VARCHAR(16777216)) as ARF_TYPE,
        cast(BUSINESS_UNIT as VARCHAR(16777216)) as BUSINESS_UNIT,
        cast(SITE as VARCHAR(16777216)) as SITE,
        cast(CATEGORY as VARCHAR(16777216)) as CATEGORY,
        cast(MODEL as VARCHAR(16777216)) as MODEL,
        cast(PROCESS as VARCHAR(16777216)) as PROCESS,
        cast(TEL_DESCRIPTION as VARCHAR(16777216)) as TEL_DESCRIPTION,
        cast(INTEL_DESCRIPTION as VARCHAR(16777216)) as INTEL_DESCRIPTION,
        cast(TEL_QUOTE_NODE_PROCESS as VARCHAR(16777216)) as TEL_QUOTE_NODE_PROCESS,
        cast(SPECIFIC_REQUEST_TYPE as VARCHAR(16777216)) as SPECIFIC_REQUEST_TYPE,
        cast(CLIENT as VARCHAR(16777216)) as CLIENT,
        cast(CLIENT_CODE as VARCHAR(16777216)) as CLIENT_CODE,
        cast(ARF_REVISION_DATE as DATE) as ARF_REVISION_DATE,
		cast(RELEASE_FROM_HOLD_DATE as DATE) as RELEASE_FROM_HOLD_DATE,
        cast(ARF_REVISION_NAME as VARCHAR(16777216)) as ARF_REVISION_NAME,
	    cast(APPROVER_COMMENT as VARCHAR(16777216)) as APPROVER_COMMENT,
        cast(TEL_COMMENT as VARCHAR(16777216)) as TEL_COMMENT
    from transform_data
    )
select * from type_data