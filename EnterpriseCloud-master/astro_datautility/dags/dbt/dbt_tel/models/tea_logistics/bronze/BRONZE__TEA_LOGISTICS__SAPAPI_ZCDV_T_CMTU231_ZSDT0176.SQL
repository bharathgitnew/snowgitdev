/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
        tags=["insert_overwrite_tea_logistics"],
    	  alias='SAPAPI_ZCDV_T_CMTU231_ZSDT0176',
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILENAME,
        _FILEDATE,
		JSONFIELD:MANDT::STRING AS MANDT,
		JSONFIELD:SEQNO::STRING AS SEQNO,
		JSONFIELD:PRC_STS::STRING AS PRC_STS,
		JSONFIELD:VKORG::STRING AS VKORG,
		JSONFIELD:ZMESID::STRING AS ZMESID,
		JSONFIELD:ZMLNO::STRING AS ZMLNO,
		JSONFIELD:ZMESD::STRING AS ZMESD,
		JSONFIELD:ZDATAT::STRING AS ZDATAT,
		JSONFIELD:ZDOCI::STRING AS ZDOCI,
		JSONFIELD:ZTRID::STRING AS ZTRID,
		JSONFIELD:ZTLNO::STRING AS ZTLNO,
		JSONFIELD:ZCUSR1::STRING AS ZCUSR1,
		JSONFIELD:ZCUSR2::STRING AS ZCUSR2,
		JSONFIELD:ZCUSSP::STRING AS ZCUSSP,
		JSONFIELD:ZCURR::STRING AS ZCURR,
		JSONFIELD:ZCUSCO::STRING AS ZCUSCO,
		JSONFIELD:ZCUSST::STRING AS ZCUSST,
		JSONFIELD:ZCUSFA::STRING AS ZCUSFA,
		JSONFIELD:ZMATNR::STRING AS ZMATNR,
		JSONFIELD:ZCUSITC::STRING AS ZCUSITC,
		JSONFIELD:ZCUSITD::STRING AS ZCUSITD,
		JSONFIELD:ZGMTCD::STRING AS ZGMTCD,
		JSONFIELD:ZQTYZ::STRING AS ZQTYZ,
		JSONFIELD:ZVRKME::STRING AS ZVRKME,
		JSONFIELD:ZCUSTRT::STRING AS ZCUSTRT,
		JSONFIELD:ZCUSTRR::STRING AS ZCUSTRR,
		JSONFIELD:ZCONT::STRING AS ZCONT,
		JSONFIELD:ZSERNR::STRING AS ZSERNR,
		JSONFIELD:ZCUSSER::STRING AS ZCUSSER,
		JSONFIELD:DEL_FLG::STRING AS DEL_FLG,
		JSONFIELD:C_DATE::STRING AS C_DATE,
		JSONFIELD:C_TIME::STRING AS C_TIME,
		JSONFIELD:C_USER::STRING AS C_USER,
		JSONFIELD:C_PGM::STRING AS C_PGM,
		JSONFIELD:U_DATE::STRING AS U_DATE,
		JSONFIELD:U_TIME::STRING AS U_TIME,
		JSONFIELD:U_USER::STRING AS U_USER,
		JSONFIELD:U_PGM::STRING AS U_PGM
    from {{ source('SAPH','SAP_SDT_EV_ZSDT0176_GMX') }}
	WHERE _FILEDATE::STRING = (
        SELECT MAX(RUN_TIME)::STRING
        FROM {{ source('SAPH', 'CONTROLTABLE') }}
        WHERE TABLE_NAME = 'SAP_SDT_EV_ZSDT0176_GMX'
        )
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:"SEQNO"::STRING ORDER BY _FILEDATE DESC, _UPLOADDATE DESC )) = 1
	),

	transform_data as (
    SELECT
        _FILENAME AS _FILENAME,
        _FILEDATE AS _FILEDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		LPAD(coalesce("SEQNO",''),10,'0') as "SEQNO",
		MANDT as MANDT,
		coalesce("PRC_STS",'') as "PRC_STS",
 	 	"VKORG",
		coalesce("ZMESID",'') as "ZMESID",
		coalesce("ZMLNO",'') as "ZMLNO",
		coalesce("ZMESD",'') as "ZMESD",
 	 	"ZDATAT",
		coalesce("ZDOCI",'') as "ZDOCI",
		coalesce("ZTRID",'') as "ZTRID",
		coalesce("ZTLNO",'') as "ZTLNO",
		coalesce("ZCUSR1",'') as "ZCUSR1",
		coalesce("ZCUSR2",'') as "ZCUSR2",
		coalesce("ZCUSSP",'') as "ZCUSSP",
		coalesce("ZCURR",'') as "ZCURR",
 	 	"ZCUSCO",
		coalesce("ZCUSST",'') as "ZCUSST",
		coalesce("ZCUSFA",'') as "ZCUSFA",
		coalesce("ZMATNR",'') as "ZMATNR",
		coalesce("ZCUSITC",'') as "ZCUSITC",
		coalesce("ZCUSITD",'') as "ZCUSITD",
		coalesce("ZGMTCD",'') as "ZGMTCD",
		coalesce("ZQTYZ",'') as "ZQTYZ",
 	 	"ZVRKME",
 	 	coalesce("ZCUSTRT",'') as "ZCUSTRT",
		coalesce("ZCUSTRR",'') as "ZCUSTRR",
		coalesce("ZCONT",'') as "ZCONT",
		coalesce("ZSERNR",'') as "ZSERNR",
		coalesce("ZCUSSER",'') as "ZCUSSER",
		Case when "DEL_FLG"='X' then 'true' else 'false' end as "DEL_FLG",
		C_USER as C_USER,
		coalesce(C_PGM,'') as C_PGM,
		U_USER as U_USER,
		U_PGM as U_PGM,
		COALESCE(REGEXP_REPLACE(TRY_TO_DATE("U_DATE"),'-',''),'') as U_DATE,
		concat(split_part(TRY_TO_TIME(U_TIME),':',1),
		split_part(TRY_TO_TIME(U_TIME),':',2),
		split_part(TRY_TO_TIME(U_TIME),':',3)
		) AS U_TIME
    FROM source_data 
),

type_data as (
    SELECT
        _FILENAME,
        _FILEDATE,
        _AUDIT_LOG_ID,
        _ROW_HASH,
		SEQNO,
		MANDT,
		PRC_STS,
		VKORG,
		ZMESID,
		ZMLNO,
		ZMESD,
		ZDATAT,
		ZDOCI,
		ZTRID,
		ZTLNO,
		ZCUSR1,
		ZCUSR2,
		ZCUSSP::number(38,2) as ZCUSSP,
		ZCURR,
		ZCUSCO,
		ZCUSST,
		ZCUSFA,
		ZMATNR,
		ZCUSITC,
		ZCUSITD,
		ZGMTCD,
		ZQTYZ,
		ZVRKME,
		ZCUSTRT,
		ZCUSTRR,
		ZCONT,
		ZSERNR,
		ZCUSSER,
		DEL_FLG,
		C_USER,
		C_PGM,
		U_USER,
		U_PGM,
		U_DATE,
		U_TIME
    FROM transform_data 
)
	select * from type_data