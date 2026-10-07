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
        FROM {{ ref('ODS__LEGACY93__CARMA_NOW_ACCRUAL') }} AS CARMA_NOW_ACCRUAL
        
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
        SO_Num, 
 	 	Line_Number, 
 	 	Part_number, 
 	 	CAST(USED_QTY AS NUMBER(38,0)) AS USED_QTY, 
 	 	Approved, 
 	 	CAST(NCDR_NUMBER AS NUMBER(38,0)) AS NCDR_NUMBER, 
 	 	CAST(PROCESS_STATUS AS NUMBER(38,0)) AS PROCESS_STATUS, 
 	 	Error_Message, 
 	 	CAST(RMA_ORDER_DATE AS TIMESTAMP_NTZ(9)) AS RMA_ORDER_DATE, 
 	 	CAST(GLOBAL_APPROVAL AS TIMESTAMP_NTZ(9)) AS GLOBAL_APPROVAL, 
 	 	Globally_Approved, 
 	 	Unit_Of_Measure
        FROM transform_data
    )
    SELECT * FROM type_data