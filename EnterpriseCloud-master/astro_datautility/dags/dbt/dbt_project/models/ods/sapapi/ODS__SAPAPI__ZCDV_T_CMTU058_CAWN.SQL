/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='merge',
    	  alias='ZCDV_T_CMTU058_CAWN',
    	  unique_key = ['ATINN',
    'ATZHL',
    'ADZHL'],
    	  transient=false	
) }} 

	with source_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		JSONFIELD:Mandt::STRING as MANDT,
		JSONFIELD:Atinn::STRING as ATINN,
		JSONFIELD:Atzhl::STRING as ATZHL,
		JSONFIELD:Adzhl::STRING as ADZHL,
		JSONFIELD:Atwrt::STRING as ATWRT,
		JSONFIELD:Atflv::STRING as ATFLV,
		JSONFIELD:Atflb::STRING as ATFLB,
		JSONFIELD:Atcod::STRING as ATCOD,
		JSONFIELD:Atstd::STRING as ATSTD,
		JSONFIELD:Atawe::STRING as ATAWE,
		JSONFIELD:Ataw1::STRING as ATAW1,
		JSONFIELD:Atidn::STRING as ATIDN,
		JSONFIELD:Spras::STRING as SPRAS,
		JSONFIELD:Txtnr::STRING as TXTNR,
		JSONFIELD:Datuv::STRING as DATUV,
		JSONFIELD:Techv::STRING as TECHV,
		JSONFIELD:Aennr::STRING as AENNR,
		JSONFIELD:Lkenz::STRING as LKENZ,
		JSONFIELD:Dokar::STRING as DOKAR,
		JSONFIELD:Doknr::STRING as DOKNR,
		JSONFIELD:Dokvr::STRING as DOKVR,
		JSONFIELD:Doktl::STRING as DOKTL,
		JSONFIELD:Atzhh::STRING as ATZHH,
		JSONFIELD:Knobj::STRING as KNOBJ,
		JSONFIELD:Atwhi::STRING as ATWHI,
		JSONFIELD:Attlv::STRING as ATTLV,
		JSONFIELD:Attlb::STRING as ATTLB,
		JSONFIELD:Atprz::STRING as ATPRZ,
		JSONFIELD:Atinc::STRING as ATINC,
		JSONFIELD:Atvpl::STRING as ATVPL,
		JSONFIELD:Datub::STRING as DATUB
	from {{ source('SAPAPI','ZCDV_T_CMTU058_CAWN') }}
	{% if is_incremental() %}WHERE  _FILEDATE >= IFNULL((SELECT MAX(_FILEDATE) FROM {{ this }}),'1970-01-01'){% endif %}
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY ATINN,ATZHL,ADZHL ORDER BY _FILENAME DESC, _FILEDATE DESC )) = 1

	),
	
	transform_data as (
	SELECT 
		_FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
		"MANDT", 
 	 	"ATINN", 
 	 	"ATZHL", 
 	 	"ADZHL", 
 	 	"ATWRT", 
 	 	"ATFLV", 
 	 	"ATFLB", 
 	 	"ATCOD", 
 	 	"ATSTD", 
 	 	"ATAWE", 
 	 	"ATAW1", 
 	 	"ATIDN", 
 	 	"SPRAS", 
 	 	"TXTNR", 
 	 	"DATUV", 
 	 	"TECHV", 
 	 	"AENNR", 
 	 	"LKENZ", 
 	 	"DOKAR", 
 	 	"DOKNR", 
 	 	"DOKVR", 
 	 	"DOKTL", 
 	 	"ATZHH", 
 	 	"KNOBJ", 
 	 	"ATWHI", 
 	 	"ATTLV", 
 	 	"ATTLB", 
 	 	"ATPRZ", 
 	 	"ATINC", 
 	 	"ATVPL", 
 	 	"DATUB"
	from source_data
	),
	
	type_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		AUDIT_LOG_ID,
        _ROW_HASH,
		"MANDT", 
 	 	"ATINN", 
 	 	"ATZHL", 
 	 	"ADZHL", 
 	 	"ATWRT", 
 	 	"ATFLV", 
 	 	"ATFLB", 
 	 	"ATCOD", 
 	 	"ATSTD", 
 	 	"ATAWE", 
 	 	"ATAW1", 
 	 	"ATIDN", 
 	 	"SPRAS", 
 	 	"TXTNR", 
 	 	"DATUV", 
 	 	"TECHV", 
 	 	"AENNR", 
 	 	"LKENZ", 
 	 	"DOKAR", 
 	 	"DOKNR", 
 	 	"DOKVR", 
 	 	"DOKTL", 
 	 	"ATZHH", 
 	 	"KNOBJ", 
 	 	"ATWHI", 
 	 	"ATTLV", 
 	 	"ATTLB", 
 	 	"ATPRZ", 
 	 	"ATINC", 
 	 	"ATVPL", 
 	 	"DATUB"
	from transform_data
	)

	select * from type_data