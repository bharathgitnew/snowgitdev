/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAPAPI_ZCDV_T_CMTU229_A916',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:MANDT::STRING AS MANDT,
		JSONFIELD:KAPPL::STRING AS KAPPL,
		JSONFIELD:KSCHL::STRING AS KSCHL,
		JSONFIELD:VKORG::STRING AS VKORG,
		JSONFIELD:KUNNR::STRING AS KUNNR,
		JSONFIELD:ZZPRCODE::STRING AS ZZPRCODE,
		JSONFIELD:ZZLEAPFLAG::STRING AS ZZLEAPFLAG,
		JSONFIELD:DATBI::STRING AS DATBI,
		JSONFIELD:DATAB::STRING AS DATAB,
		JSONFIELD:KNUMH::STRING AS KNUMH
    FROM {{ source('SAPH','SAP_SDM_EV_A916_GMX') }}
	WHERE _FILEDATE::STRING = (
        SELECT MAX(RUN_TIME)::STRING
        FROM {{ source('SAPH', 'CONTROLTABLE') }}
        WHERE TABLE_NAME = 'SAP_SDM_EV_A916_GMX'
        )    
	QUALIFY ROW_NUMBER() OVER ( PARTITION BY DATBI, KAPPL, KSCHL, KUNNR, VKORG, ZZLEAPFLAG, ZZPRCODE ORDER BY _FILEDATE DESC, _UPLOADDATE DESC) = 1
	),
	
	transform_data as (
    SELECT
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        KAPPL as KAPPL,
        LPAD("KNUMH",10,'0') AS KNUMH,--Changes as a part of GMX migration
        KSCHL as KSCHL,
        KUNNR as KUNNR,
        VKORG as VKORG,
        ZZPRCODE as ZZPRCODE,
        ZZLEAPFLAG as ZZLEAPFLAG,
        REGEXP_REPLACE(TRY_TO_DATE("DATAB"),'-','') AS DATAB,--Changes as a part of GMX migration
        COALESCE(REGEXP_REPLACE(TRY_TO_DATE("DATBI"),'-',''),'') AS DATBI,--Changes as a part of GMX migration
        MANDT as MANDT
FROM source_data 
),

type_data as (
    SELECT
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        KAPPL,
        KNUMH,
        KSCHL,
        KUNNR,
        VKORG,
        ZZPRCODE,
        ZZLEAPFLAG,
        DATAB,
        DATBI,
        MANDT
FROM transform_data 
)

	select * from type_data