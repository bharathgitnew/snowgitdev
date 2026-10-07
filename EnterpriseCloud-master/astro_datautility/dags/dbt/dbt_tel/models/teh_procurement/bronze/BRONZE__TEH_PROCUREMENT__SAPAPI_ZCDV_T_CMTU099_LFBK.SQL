/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAPAPI_ZCDV_T_CMTU099_LFBK',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:Mandt::STRING AS MANDT,
		JSONFIELD:Lifnr::STRING AS LIFNR,
		JSONFIELD:Banks::STRING AS BANKS,
		JSONFIELD:Bankl::STRING AS BANKL,
		JSONFIELD:Bankn::STRING AS BANKN,
		JSONFIELD:Bkont::STRING AS BKONT,
		JSONFIELD:Bvtyp::STRING AS BVTYP,
		JSONFIELD:Xezer::STRING AS XEZER,
		JSONFIELD:Bkref::STRING AS BKREF,
		JSONFIELD:Koinh::STRING AS KOINH,
		JSONFIELD:EbppAccname::STRING AS EBPPACCNAME,
		JSONFIELD:EbppBvstatus::STRING AS EBPPBVSTATUS,
		JSONFIELD:Kovon::STRING AS KOVON,
		JSONFIELD:Kobis::STRING AS KOBIS
    FROM {{ source('SAPAPI','ZCDV_T_CMTU099_LFBK') }}
    where _FILEDATE = (select ifnull(try_to_timestamp_ntz(max(MAX_FILE_DATE), 'YYYY-MM-DD_hh_mi_ss_ff6'), '1970-01-01') from {{ source('SAPAPI', 'CONTROLTABLE') }} where TABLE_NAME = 'ZCDV_T_CMTU099')

	),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		LIFNR as LIFNR,
		BANKS as BANKS,
		BANKL as BANKL,
		BANKN as BANKN,
		BKONT as BKONT,
		BVTYP as BVTYP,
		XEZER as XEZER,
		BKREF as BKREF,
		KOINH as KOINH,
		EBPPACCNAME as EBPPACCNAME,
		EBPPBVSTATUS as EBPPBVSTATUS,
		KOVON as KOVON,
		KOBIS as KOBIS
    FROM source_data 
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        _AUDIT_LOG_ID,
        _ROW_HASH,
		LIFNR,
		BANKS,
		BANKL,
		BANKN,
		BKONT,
		BVTYP,
		XEZER,
		BKREF,
		KOINH,
		EBPPACCNAME,
		EBPPBVSTATUS,
		KOVON,
		KOBIS
    FROM transform_data 
)

	select * from type_data