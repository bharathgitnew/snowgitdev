{{ config(
    	  materialized='incremental',
    	  incremental_strategy='merge',
    	  alias='TTCMCS030200',
    	  unique_key = ['T$SKLL'],
    	  transient=false	
) }} 

	with source_data as (
	SELECT
      	
		TTCMCS030200."T$SKLL" AS "T$SKLL", 
 	 	TTCMCS030200."T$DESC" AS "T$DESC", 
 	 	TTCMCS030200."T$REFCNTD" AS "T$REFCNTD", 
 	 	TTCMCS030200."T$REFCNTU" AS "T$REFCNTU", 
 	 	TTCMCS030200."_CAPTUREDATETIME" AS "_CAPTUREDATETIME", 
 	 	TTCMCS030200."_INTEGRATEDATETIME" AS "_INTEGRATEDATETIME", 
 	 	TTCMCS030200."_INTEGRATIONKEY" AS "_INTEGRATIONKEY", 
 	 	TTCMCS030200."_TRANSACTIONTYPE" AS "_TRANSACTIONTYPE"
                	
	from {{ source('BAAN3_ORACLE_LIVE','TTCMCS030200') }} AS TTCMCS030200 
     
	

	),
	
	transform_data as (
	SELECT 
		"T$SKLL", 
 	 	"T$DESC", 
 	 	"T$REFCNTD", 
 	 	"T$REFCNTU", 
 	 	"_CAPTUREDATETIME", 
 	 	"_INTEGRATEDATETIME", 
 	 	"_INTEGRATIONKEY", 
 	 	"_TRANSACTIONTYPE",
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
	from source_data
	),
	
	type_data as (
	SELECT
		CAST("T$SKLL" AS VARCHAR(16777216)) AS "T$SKLL", 
 	 	CAST("T$DESC" AS VARCHAR(16777216)) AS "T$DESC", 
 	 	CAST("T$REFCNTD" AS NUMBER(38,10)) AS "T$REFCNTD", 
 	 	CAST("T$REFCNTU" AS NUMBER(38,10)) AS "T$REFCNTU", 
 	 	CAST("_CAPTUREDATETIME" AS TIMESTAMP_LTZ(9)) AS "_CAPTUREDATETIME", 
 	 	CAST("_INTEGRATEDATETIME" AS TIMESTAMP_LTZ(9)) AS "_INTEGRATEDATETIME", 
 	 	CAST("_INTEGRATIONKEY" AS VARCHAR(16777216)) AS "_INTEGRATIONKEY", 
 	 	CAST("_TRANSACTIONTYPE" AS NUMBER(38,10)) AS "_TRANSACTIONTYPE",
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH 
    from transform_data
	)

	select * from type_data