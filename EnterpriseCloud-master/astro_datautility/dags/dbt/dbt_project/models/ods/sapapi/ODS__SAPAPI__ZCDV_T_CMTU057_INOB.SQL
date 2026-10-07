	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='ZCDV_T_CMTU057_INOB',
    	  unique_key = [''],
    	  transient=false,
		  tags = ['daily_12am']	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:"Mandt"::STRING AS MANDT, -- No Mapping in GMX
		JSONFIELD:"CUOBJ"::STRING AS CUOBJ,
		JSONFIELD:"KLART"::STRING AS KLART,
		JSONFIELD:"OBTAB"::STRING AS OBTAB,
		JSONFIELD:"OBJEK"::STRING AS OBJEK,
		JSONFIELD:"ROBTAB"::STRING AS ROBTAB,
		JSONFIELD:"ROBJEK"::STRING AS ROBJEK,
		JSONFIELD:"CLINT"::STRING AS CLINT,
		JSONFIELD:"STATU"::STRING AS STATU,
		JSONFIELD:"CUCOZHL"::STRING AS CUCOZHL,
		JSONFIELD:"PARENT"::STRING AS PARENT,
		JSONFIELD:"ROOT"::STRING AS ROOT,
		JSONFIELD:"EXPERTE"::STRING AS EXPERTE,
		JSONFIELD:"MATNR"::STRING AS MATNR,
		JSONFIELD:"DATUV"::STRING AS DATUV,
		JSONFIELD:"TECHS"::STRING AS TECHS
	from {{ source('SAPH','SAP_ZZM_EV_INOB') }}
	WHERE _FILEDATE::STRING = (
        SELECT MAX(RUN_TIME)::STRING
        FROM {{ source('SAPH', 'CONTROLTABLE') }}
        WHERE TABLE_NAME = 'SAP_ZZM_EV_INOB'
        )
	QUALIFY ROW_NUMBER() OVER ( PARTITION BY CUOBJ ORDER BY _FILEDATE DESC, _UPLOADDATE DESC) = 1
	),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		MANDT as MANDT,
		LPAD(coalesce("CUOBJ",''),18,'0') as "CUOBJ",
		LPAD(coalesce("KLART",''),3,'0') as "KLART",
		OBTAB as OBTAB,
		OBJEK as OBJEK,
		coalesce("ROBTAB",'') as "ROBTAB",
		coalesce("ROBJEK",'') as "ROBJEK",
		LPAD(coalesce("CLINT",''),10,'0') as "CLINT",
		coalesce("STATU",'') as "STATU",
		LPAD(coalesce("CUCOZHL",''),4,'0') as "CUCOZHL",
		LPAD(coalesce("PARENT",''),18,'0') as "PARENT",
		LPAD(coalesce("ROOT",''),18,'0') as "ROOT",
		coalesce("EXPERTE",'') as "EXPERTE",
		coalesce("MATNR",'') as "MATNR",
		LPAD(coalesce("DATUV",''),8,'0') as "DATUV",
		coalesce("TECHS",'') as "TECHS"
    FROM source_data 
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        AUDIT_LOG_ID,
        _ROW_HASH,
		MANDT,
		CUOBJ,
		KLART,
		OBTAB,
		OBJEK,
		ROBTAB,
		ROBJEK,
		CLINT,
		STATU,
		CUCOZHL,
		PARENT,
		ROOT,
		EXPERTE,
		MATNR,
		DATUV,
		TECHS
    FROM transform_data 
)

	select * from type_data