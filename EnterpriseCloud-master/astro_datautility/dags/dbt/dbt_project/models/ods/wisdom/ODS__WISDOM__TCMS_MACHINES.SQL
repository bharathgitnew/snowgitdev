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
        JSONFIELD:"SERIAL_NUMBER"::STRING AS SERIAL_NUMBER, 
 	 	JSONFIELD:"CUSTOMER_BP_9_DIGITS"::STRING AS CUSTOMER_BP_9_DIGITS, 
 	 	JSONFIELD:"MODEL_OF_TOOL"::STRING AS MODEL_OF_TOOL, 
 	 	JSONFIELD:"ORIGINAL_TC_SOLD"::STRING AS ORIGINAL_TC_SOLD, 
 	 	JSONFIELD:"TC_AVAILABLE"::STRING AS TC_AVAILABLE, 
 	 	JSONFIELD:"TC_EXPIRATION_DATE"::STRING AS TC_EXPIRATION_DATE, 
 	 	JSONFIELD:"WARRANTY_START_DATE"::STRING AS WARRANTY_START_DATE, 
 	 	JSONFIELD:"WARRANTY_END_DATE"::STRING AS WARRANTY_END_DATE
        FROM {{ source('WISDOM', 'TCMS_MACHINES') }} AS TCMS_MACHINES
        WHERE _FILEDATE = (
            SELECT MAX(RUN_TIME)
            FROM {{ source('WISDOM', 'CONTROLTABLE') }}
            WHERE TABLE_NAME = 'V_TCMS_US'
)
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