/************
	Model file generated from SAPAPIUtility 
	*************/

	-- disabled due to no SAP data
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='merge',
    	  alias='SAPAPI_ZCDV_T_CMTU086_A919',
    	  unique_key = ['KAPPL',
    'KSCHL',
    'VKORG',
    'AUGRU',
    'KFRST',
    'DATBI'],
    	  transient=false	
) }} 

	with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		JSONFIELD:KAPPL::STRING AS KAPPL, 
 	 	JSONFIELD:KSCHL::STRING AS KSCHL, 
 	 	JSONFIELD:VKORG::STRING AS VKORG, 
 	 	JSONFIELD:AUGRU::STRING AS AUGRU, 
 	 	JSONFIELD:KFRST::STRING AS KFRST, 
 	 	JSONFIELD:DATBI::STRING AS DATBI, 
 	 	JSONFIELD:DATAB::STRING AS DATAB, 
 	 	JSONFIELD:KBSTAT::STRING AS KBSTAT, 
 	 	JSONFIELD:KNUMH::STRING AS KNUMH, 
 	 	JSONFIELD:update_date::STRING AS update_date
	from {{ source('SAPAPI', 'ZCDV_T_CMTU086_A919') }}
	WHERE 1=2
/* Adding false filter to the model so that we can enable it for DBT Project Consolidation, related to changes in k-card 34754 */
	--{% if is_tel_incremental() %}WHERE  _FILEDATE > IFNULL((SELECT MAX(_FILEDATE) FROM {{ this }}:1970-01-01'){% endif %}
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:KAPPL::STRING,JSONFIELD:KSCHL::STRING,JSONFIELD:VKORG::STRING,JSONFIELD:AUGRU::STRING,JSONFIELD:KFRST::STRING,JSONFIELD:DATBI::STRING  ORDER BY _FILENAME DESC, _FILEDATE DESC )) = 1

	),
	
	transform_data as (
	SELECT 
		_FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.
		KAPPL, 
 	 	KSCHL, 
 	 	VKORG, 
 	 	AUGRU, 
 	 	KFRST, 
 	 	DATBI, 
 	 	DATAB, 
 	 	KBSTAT, 
 	 	KNUMH, 
 	 	update_date
		
	from source_data
	),
	
	type_data as (
	SELECT
		cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		cast(_FILENAME as varchar(128)) as _FILENAME,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
		 KAPPL, 
 	 	 KSCHL, 
 	 	 VKORG, 
 	 	 AUGRU, 
 	 	 KFRST, 
 	 	 DATBI, 
 	 	 DATAB, 
 	 	 KBSTAT, 
 	 	 KNUMH, 
 	 	 update_date
	from transform_data
	)

	select * from type_data