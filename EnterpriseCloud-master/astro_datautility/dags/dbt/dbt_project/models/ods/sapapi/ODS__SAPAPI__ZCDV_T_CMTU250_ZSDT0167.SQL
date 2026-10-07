/************
    Model file generated from SAPAPIUtility 
    *************/
    
    
    {{ config(
          materialized='incremental',
          incremental_strategy='insert_overwrite',
          alias='ZCDV_T_CMTU250_ZSDT0167',
          transient=false    
) }} 
    
    with source_data as (
        SELECT
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE,
		JSONFIELD:ZOZZZ::STRING as ZOZZZ,
		JSONFIELD:ZDZZZ::STRING as ZDZZZ,
		JSONFIELD:ZDIZZ::STRING as ZDIZZ,
		JSONFIELD:ZSLZZ::STRING as ZSLZZ,
		JSONFIELD:ZLST::STRING as ZLST,
		JSONFIELD:MATNR::STRING as MATNR,
		JSONFIELD:ZRQZZ::STRING as ZRQZZ,
		JSONFIELD:ZBUZZ::STRING as ZBUZZ,
		JSONFIELD:ZGDOLS::STRING as ZGDOLS,
		JSONFIELD:ZTOEZ::STRING as ZTOEZ,
		JSONFIELD:ZCCIIM::STRING as ZCCIIM,
		JSONFIELD:ZSCWN::STRING as ZSCWN,
		JSONFIELD:DEL_FLG::STRING as DEL_FLG,
		JSONFIELD:C_DATE::STRING as C_DATE,
		JSONFIELD:C_TIME::STRING as C_TIME,
		JSONFIELD:C_USER::STRING as C_USER,
		JSONFIELD:C_PGM::STRING as C_PGM,
		JSONFIELD:U_DATE::STRING as U_DATE,
		JSONFIELD:U_TIME::STRING as U_TIME,
		JSONFIELD:U_USER::STRING as U_USER,
		JSONFIELD:U_PGM::STRING as U_PGM
	from {{ source('SAPH','SAP_SDT_EV_ZSDT0167_GMX') }}
	WHERE _FILEDATE::STRING = (
        SELECT MAX(RUN_TIME)::STRING
        FROM {{ source('SAPH', 'CONTROLTABLE') }}
        WHERE TABLE_NAME = 'SAP_SDT_EV_ZSDT0167_GMX'
        )
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:"ZOZZZ"::STRING,JSONFIELD:"ZDZZZ"::STRING,JSONFIELD:"ZDIZZ"::STRING,JSONFIELD:"ZSLZZ"::STRING  ORDER BY _FILEDATE DESC )) = 1
	),
    transform_data as (
        SELECT
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        ZOZZZ,
		ZDZZZ,
		LPAD("ZDIZZ",6,'0') AS "ZDIZZ",
 	 	LPAD("ZSLZZ",4,'0') AS "ZSLZZ",
 	 	COALESCE("ZLST",'') AS "ZLST",
		MATNR,
		ZRQZZ,
		ZBUZZ,
		TO_DATE(TRIM(ZGDOLS,'/Date()/'))::VARCHAR as ZGDOLS,
		concat('PT', split_part(TRY_TO_TIME(ZTOEZ),':',1),'H',
		split_part(TRY_TO_TIME(ZTOEZ),':',2),'M',
		split_part(TRY_TO_TIME(ZTOEZ),':',3),'S'
		) AS ZTOEZ,
		coalesce(ZCCIIM,'') as ZCCIIM,
		coalesce( LPAD(ZSCWN,8,'0'),'') as ZSCWN,
		DEL_FLG,
		TO_DATE(TRIM("C_DATE",'/Date()/'))::VARCHAR AS "C_DATE", 
		concat('PT', split_part(TRY_TO_TIME(C_TIME),':',1),'H',
		split_part(TRY_TO_TIME(C_TIME),':',2),'M',
		split_part(TRY_TO_TIME(C_TIME),':',3),'S'
		) as "C_TIME", 
		"C_USER", 
		"C_PGM", 
		TO_DATE(TRIM("U_DATE",'/Date()/'))::VARCHAR AS "U_DATE", 
		concat('PT', split_part(TRY_TO_TIME(U_TIME),':',1),'H',
		split_part(TRY_TO_TIME(U_TIME),':',2),'M',
		split_part(TRY_TO_TIME(U_TIME),':',3),'S'
		) AS U_TIME,
		coalesce(U_USER,'') as U_USER,
		coalesce(U_PGM,'') as U_PGM
        FROM source_data
    ),
    type_data as (
        SELECT
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE,
		_AUDIT_LOG_ID,
        _ROW_HASH,
        "ZOZZZ", 
 	 	"ZDZZZ", 
 	 	"ZDIZZ", 
 	 	"ZSLZZ", 
 	 	"ZLST", 
 	 	"MATNR", 
 	 	"ZRQZZ", 
 	 	"ZBUZZ", 
 	 	"ZGDOLS", 
 	 	"ZTOEZ", 
 	 	"ZCCIIM", 
 	 	"ZSCWN", 
 	 	"DEL_FLG", 
 	 	"C_DATE", 
 	 	"C_TIME", 
 	 	"C_USER", 
 	 	"C_PGM", 
 	 	"U_DATE", 
 	 	"U_TIME", 
 	 	"U_USER", 
 	 	"U_PGM"
        FROM transform_data
    )
    SELECT * FROM type_data