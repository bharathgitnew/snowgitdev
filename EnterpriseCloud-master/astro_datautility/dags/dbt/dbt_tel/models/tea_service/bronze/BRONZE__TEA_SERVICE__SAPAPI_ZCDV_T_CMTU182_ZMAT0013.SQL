/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='merge',
    	  alias='SAPAPI_ZCDV_T_CMTU182_ZMAT0013',
    	  unique_key = ['PARTNER',
    'ZDUTY',
    'ZAJC'],
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:Mandt::STRING AS MANDT,
		JSONFIELD:Partner::STRING AS PARTNER,
		JSONFIELD:Zduty::STRING AS ZDUTY,
		JSONFIELD:Zajc::STRING AS ZAJC,
		JSONFIELD:Seqno::STRING AS SEQNO,
		JSONFIELD:PrcSts::STRING AS PRCSTS,
		JSONFIELD:Zcomc::STRING AS ZCOMC,
		JSONFIELD:Zcostc::STRING AS ZCOSTC,
		JSONFIELD:Zgpc::STRING AS ZGPC,
		JSONFIELD:Country::STRING AS COUNTRY,
		JSONFIELD:Zjobfg::STRING AS ZJOBFG,
		JSONFIELD:Zjobf::STRING AS ZJOBF,
		JSONFIELD:Zposition::STRING AS ZPOSITION,
		JSONFIELD:DelFlg::STRING AS DELFLG,
		JSONFIELD:CDate::STRING AS CDATE,
		JSONFIELD:CTime::STRING AS CTIME,
		JSONFIELD:CUser::STRING AS CUSER,
		JSONFIELD:CPgm::STRING AS CPGM,
		JSONFIELD:UDate::STRING AS UDATE,
		JSONFIELD:UTime::STRING AS UTIME,
		JSONFIELD:UUser::STRING AS UUSER,
		JSONFIELD:UPgm::STRING AS UPGM
    FROM {{ source('SAPAPI','ZCDV_T_CMTU182_ZMAT0013') }}
	{% if is_tel_incremental() %}WHERE  _FILEDATE >= IFNULL((SELECT MAX(_FILEDATE) FROM {{ this }}),'1970-01-01'){% endif %}
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY PARTNER,ZDUTY,ZAJC  ORDER BY _FILENAME DESC, _FILEDATE DESC )) = 1

	),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		PARTNER as PARTNER,
		ZDUTY as ZDUTY,
		ZAJC as ZAJC,
		SEQNO as SEQNO,
		PRCSTS as PRCSTS,
		ZCOMC as ZCOMC,
		ZCOSTC as ZCOSTC,
		ZGPC as ZGPC,
		COUNTRY as COUNTRY,
		ZJOBFG as ZJOBFG,
		ZJOBF as ZJOBF,
		ZPOSITION as ZPOSITION,
		DELFLG as DELFLG,
		CDATE as CDATE,
		CTIME as CTIME,
		CUSER as CUSER,
		CPGM as CPGM,
		UTIME as UTIME,
		UUSER as UUSER,
		UPGM as UPGM,
		UDATE as UDATE
    FROM source_data 
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        AUDIT_LOG_ID,
        _ROW_HASH,
		PARTNER,
		ZDUTY,
		ZAJC,
		SEQNO,
		PRCSTS,
		ZCOMC,
		ZCOSTC,
		ZGPC,
		COUNTRY,
		ZJOBFG,
		ZJOBF,
		ZPOSITION,
		DELFLG,
		CDATE,
		CTIME,
		CUSER,
		CPGM,
		UTIME,
		UUSER,
		UPGM,
		UDATE
    FROM transform_data 
)

	select * from type_data