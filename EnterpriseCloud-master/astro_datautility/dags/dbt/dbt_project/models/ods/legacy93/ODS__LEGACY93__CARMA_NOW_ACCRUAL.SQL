/************
    Model file generated from TelTool SQL SERVER Ingestion Utility 
    *************/
    

    {{ config(
            materialized='incremental',
            incremental_strategy='insert_overwrite',
            alias='CARMA_NOW_ACCRUAL',
            unique_key=[],
            transient=false    
) }} 
    
    with source_data as (
        SELECT
        _FILEDATE,
		_FILENAME,
        JSONFIELD:"SO_Num"::STRING AS SO_Num, 
 	 	JSONFIELD:"Line_Number"::STRING AS Line_Number, 
 	 	JSONFIELD:"Part_number"::STRING AS Part_number, 
 	 	JSONFIELD:"Used_Qty"::NUMBER AS Used_Qty, 
 	 	JSONFIELD:"Approved"::STRING AS Approved, 
 	 	JSONFIELD:"NCDR_Number"::NUMBER AS NCDR_Number, 
 	 	JSONFIELD:"Process_Status"::NUMBER AS Process_Status, 
 	 	JSONFIELD:"Error_Message"::STRING AS Error_Message, 
 	 	REGEXP_REPLACE(JSONFIELD:"rma_order_date", '\/Date\\(|\\)\/', '')::TIMESTAMP AS rma_order_date, 
 	 	REGEXP_REPLACE(JSONFIELD:"Global_Approval", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Global_Approval, 
 	 	JSONFIELD:"Globally_Approved"::STRING AS Globally_Approved, 
 	 	JSONFIELD:"Unit_Of_Measure"::STRING AS Unit_Of_Measure
        FROM {{ source('LEGACY93', 'CARMA_NOW_ACCRUAL') }} AS CARMA_NOW_ACCRUAL
        WHERE _FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('LEGACY93', 'CARMA_NOW_ACCRUAL') }})
    ),
    transform_data as (
        SELECT
        _FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        SO_NUM, 
 	 	LINE_NUMBER, 
 	 	PART_NUMBER, 
 	 	USED_QTY, 
 	 	APPROVED, 
 	 	NCDR_NUMBER, 
 	 	PROCESS_STATUS, 
 	 	ERROR_MESSAGE, 
 	 	RMA_ORDER_DATE, 
 	 	GLOBAL_APPROVAL, 
 	 	GLOBALLY_APPROVED, 
 	 	UNIT_OF_MEASURE
        FROM source_data
    ),
    type_data as (
        SELECT
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        SO_NUM, 
 	 	LINE_NUMBER, 
 	 	PART_NUMBER, 
 	 	CAST(USED_QTY AS NUMBER(38,0)) AS USED_QTY, 
 	 	APPROVED, 
 	 	CAST(NCDR_NUMBER AS NUMBER(38,0)) AS NCDR_NUMBER, 
 	 	CAST(PROCESS_STATUS AS NUMBER(38,0)) AS PROCESS_STATUS, 
 	 	ERROR_MESSAGE, 
 	 	CAST(RMA_ORDER_DATE AS TIMESTAMP_NTZ(9)) AS RMA_ORDER_DATE, 
 	 	CAST(GLOBAL_APPROVAL AS TIMESTAMP_NTZ(9)) AS GLOBAL_APPROVAL, 
 	 	GLOBALLY_APPROVED, 
 	 	UNIT_OF_MEASURE
        FROM transform_data
    )
    SELECT * FROM type_data