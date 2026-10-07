/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='merge',
    	  alias='SAPAPI_ZCDV_T_CMTU210_CDHDR',
    	  unique_key = ['OBJECTCLAS',
    'OBJECTID',
    'CHANGENR',
    'TABNAME',
    'TABKEY',
    'FNAME',
    'CHNGIND'],
    	  tags=["finance"],
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:Mandt::STRING AS MANDT,
		JSONFIELD:Objectclas::STRING AS OBJECTCLAS,
		JSONFIELD:Objectid::STRING AS OBJECTID,
		JSONFIELD:Changenr::STRING AS CHANGENR,
		JSONFIELD:Tabname::STRING AS TABNAME,
		JSONFIELD:Tabkey::STRING AS TABKEY,
		JSONFIELD:Fname::STRING AS FNAME,
		JSONFIELD:Chngind::STRING AS CHNGIND,
		JSONFIELD:Username::STRING AS USERNAME,
		JSONFIELD:Udate::STRING AS UDATE,
		JSONFIELD:Utime::STRING AS UTIME,
		JSONFIELD:Tcode::STRING AS TCODE,
		JSONFIELD:Planchngnr::STRING AS PLANCHNGNR,
		JSONFIELD:ActChngno::STRING AS ACTCHNGNO,
		JSONFIELD:WasPlannd::STRING AS WASPLANND,
		JSONFIELD:Langu::STRING AS LANGU,
		JSONFIELD:Version::STRING AS VERSION
    FROM {{ source('SAPAPI','ZCDV_T_CMTU210_CDHDR') }}
	{% if is_tel_incremental() %}WHERE  _FILEDATE > IFNULL((SELECT MAX(_FILEDATE) FROM {{ this }}),'1970-01-01'){% endif %}
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY OBJECTCLAS,OBJECTID,CHANGENR,TABNAME,TABKEY,FNAME,CHNGIND  ORDER BY _FILENAME DESC, _FILEDATE DESC )) = 1

	),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		OBJECTCLAS as OBJECTCLAS,
		OBJECTID as OBJECTID,
		CHANGENR as CHANGENR,
		TABNAME as TABNAME,
		TABKEY as TABKEY,
		FNAME as FNAME,
		CHNGIND as CHNGIND,
		USERNAME as USERNAME,
		UDATE as UDATE,
		UTIME as UTIME,
		TCODE as TCODE,
		PLANCHNGNR as PLANCHNGNR,
		ACTCHNGNO as ACT_CHNGNO,
		WASPLANND as WAS_PLANND,
		LANGU as LANGU,
		VERSION as VERSION
    FROM source_data 
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        AUDIT_LOG_ID,
        _ROW_HASH,
		OBJECTCLAS,
		OBJECTID,
		CHANGENR,
		TABNAME,
		TABKEY,
		FNAME,
		CHNGIND,
		USERNAME,
		UDATE,
		UTIME,
		TCODE,
		PLANCHNGNR,
		ACT_CHNGNO,
		WAS_PLANND,
		LANGU,
		VERSION
    FROM transform_data 
)

	select * from type_data