/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='merge',
    	  alias='ZCDV_T_CMTU121_SKAT',
    	  unique_key = ['SPRAS',
    'KTOPL',
    'SAKNR'],
    	  transient=false	
) }} 

	
with source_data as ( 
    SELECT
        _FILEDATE,
		_FILENAME,
		JSONFIELD:gl_acct::STRING AS SAKNR,
		JSONFIELD:chrt_accts::STRING AS KTOPL,
		JSONFIELD:gl_acct_type::STRING AS GLACCOUNT_TYPE,
		JSONFIELD:acct_group::STRING AS KTOKS,
		JSONFIELD:short_text::STRING AS TXT20,
		JSONFIELD:long_text::STRING AS TXT50,
		JSONFIELD:group_acct::STRING AS BILKT,
		JSONFIELD:language::STRING AS SPRAS,
		JSONFIELD:create_date::STRING AS ERDAT,
		JSONFIELD:created_by::STRING AS ERNAM,
		JSONFIELD:group_chrt_accts::STRING AS KKTPL,
		JSONFIELD:creation_date::STRING AS CDATE,
		JSONFIELD:creation_time::STRING AS CTIME,
		JSONFIELD:creation_datetime::STRING AS CDATM,
		JSONFIELD:update_date::STRING AS UPDATE_DATE,
		JSONFIELD:update_time::STRING AS UTIME,
		JSONFIELD:update_datetime::STRING AS UDATM,
		JSONFIELD:deletion_flag::STRING AS XLOEV
    FROM 
     {{ source('SAPAPI','ZCDV_CM0280_10_SKAT') }}
	{% if is_incremental() %}WHERE  _FILEDATE >= IFNULL((SELECT MAX(_FILEDATE) FROM {{ this }}),'1970-01-01'){% endif %}
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY SPRAS,KTOPL,SAKNR  ORDER BY _FILENAME DESC, _FILEDATE DESC )) = 1

	),
	
	
transform_data as ( 
    SELECT
        _FILEDATE AS _FILEDATE,
		_FILENAME AS _FILENAME,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		SPRAS AS SPRAS,
		KTOPL as KTOPL,
		SAKNR as SAKNR,
		TXT20 as TXT20,
		TXT50 as TXT50,
		NULL AS MCOD1,
		NULL AS LASTCHANGEDTS,
		UPDATE_DATE AS UPDATE_DATE
    FROM 
     source_data 
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        AUDIT_LOG_ID,
        _ROW_HASH,
		SPRAS,
		KTOPL,
		SAKNR,
		TXT20,
		TXT50,
		MCOD1,
		LASTCHANGEDTS,
		UPDATE_DATE
    FROM transform_data 
)

	select * from type_data