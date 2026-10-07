/************
	Model file generated from gmxUtility 
	*************/

	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='merge',
    	  alias='FILELIST',
    	  unique_key = [],
    	  transient=false,
		  tags = ['on_demand']	
) }}

	with source_data as (
	SELECT
		JSONFIELD:"RecordCount"::STRING AS "RECORDCOUNT", 
 	 	JSONFIELD:"TableOrViewName"::STRING AS "TABLEORVIEWNAME",
		_FILEDATE,
		_FILENAME
	from {{ source('SAPH','FILELIST') }}
	{% if is_incremental() %}WHERE  _FileDate > IFNULL((SELECT MAX(_FileDate) FROM {{ this }}),'1970-01-01'){% endif %}

	),
	
	transform_data as (
	SELECT 
		"RECORDCOUNT", 
 	 	"TABLEORVIEWNAME",
		case 
			when tableorviewname = 'SF_SAP_US_SDT_EV_LIPSSF_GMX' then 'SAP_US_SDT_EV_LIPS' 
			when tableorviewname = 'SF_SAP_US_SDT_EV_VBAKEX_GMX' then 'SAP_US_SDT_EV_VBAK'
			else UPPER(REGEXP_REPLACE(tableorviewname,'^SF_|_GMX$','')) 
		end as SCRUBBED_TABLE_NAME,
		_FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
	from source_data
	),
	
	type_data as (
	SELECT
		CAST("RECORDCOUNT" AS VARCHAR(16777216)) AS "RECORDCOUNT", 
 	 	CAST("TABLEORVIEWNAME" AS VARCHAR(16777216)) AS "TABLEORVIEWNAME",
 	 	CAST(SCRUBBED_TABLE_NAME AS VARCHAR(16777216)) AS SCRUBBED_TABLE_NAME,
		cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		cast(_FILENAME as varchar(128)) as _FILENAME,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
	from transform_data
	)

	select * from type_data