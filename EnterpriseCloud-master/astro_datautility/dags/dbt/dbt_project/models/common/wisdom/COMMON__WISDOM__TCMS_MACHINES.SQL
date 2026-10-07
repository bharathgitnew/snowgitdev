/************
    Model file generated from TelTool SQL SERVER Ingestion Utility 
    *************/
    

    {{ config(
            materialized='incremental',
            incremental_strategy='insert_overwrite',
            alias='TCMS_MACHINES',
            unique_key=[],
            transient=false    
) }} 
    
    with source_data as (
        SELECT
        _FILEDATE,
		_FILENAME,
        SERIAL_NUMBER, 
 	 	CUSTOMER_BP_9_DIGITS, 
 	 	MODEL_OF_TOOL, 
 	 	ORIGINAL_TC_SOLD, 
 	 	TC_AVAILABLE, 
 	 	TC_EXPIRATION_DATE, 
 	 	WARRANTY_START_DATE, 
 	 	WARRANTY_END_DATE
        FROM {{ ref('ODS__WISDOM__TCMS_MACHINES') }} AS TCMS_MACHINES
        
    ),
    transform_data as (
        SELECT
        _FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        SERIAL_NUMBER, 
 	 	CUSTOMER_BP_9_DIGITS, 
 	 	MODEL_OF_TOOL, 
 	 	ORIGINAL_TC_SOLD, 
 	 	TC_AVAILABLE, 
 	 	TC_EXPIRATION_DATE, 
 	 	WARRANTY_START_DATE, 
 	 	WARRANTY_END_DATE
        FROM source_data
    ),
    type_data as (
        SELECT
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        SERIAL_NUMBER, 
 	 	CUSTOMER_BP_9_DIGITS, 
 	 	MODEL_OF_TOOL, 
 	 	ORIGINAL_TC_SOLD, 
 	 	TC_AVAILABLE, 
 	 	TC_EXPIRATION_DATE, 
 	 	WARRANTY_START_DATE, 
 	 	WARRANTY_END_DATE
        FROM transform_data
    )
    SELECT * FROM type_data