/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAPAPI_ZCDV_T_CMTU114_SKA1',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
			_FILEDATE,
			_FILENAME,
			JSONFIELD:"Mandt"::STRING AS MANDT, -- No Mapping in GMX
			JSONFIELD:"KTOPL"::STRING AS KTOPL,
			JSONFIELD:"SAKNR"::STRING AS SAKNR,
			JSONFIELD:"XBILK"::STRING AS XBILK,
			JSONFIELD:"SAKAN"::STRING AS SAKAN,
			JSONFIELD:"BILKT"::STRING AS BILKT,
			JSONFIELD:"ERDAT"::STRING AS ERDAT,
			JSONFIELD:"ERNAM"::STRING AS ERNAM,
			JSONFIELD:"GVTYP"::STRING AS GVTYP,
			JSONFIELD:"KTOKS"::STRING AS KTOKS,
			JSONFIELD:"Mustr"::STRING AS MUSTR, -- No Mapping in GMX
			JSONFIELD:"Vbund"::STRING AS VBUND, -- No Mapping in GMX
			JSONFIELD:"XLOEV"::STRING AS XLOEV,
			JSONFIELD:"XSPEA"::STRING AS XSPEA,
			JSONFIELD:"XSPEB"::STRING AS XSPEB,
			JSONFIELD:"XSPEP"::STRING AS XSPEP,
			JSONFIELD:"MCOD1"::STRING AS MCOD1,
			JSONFIELD:"FuncArea"::STRING AS FUNCAREA, -- No Mapping in GMX
			JSONFIELD:"GLACCOUNT_TYPE"::STRING AS GLACCOUNTTYPE,
			JSONFIELD:"LastChangedTs"::STRING AS LASTCHANGEDTS, -- No Mapping in GMX
			JSONFIELD:"update_date"::STRING AS UPDATE_DATE -- No Mapping in GMX
		from {{ source('SAPH','SAP_FIM_EV_SKA1') }}
			WHERE _FILEDATE::STRING = (
        SELECT MAX(RUN_TIME)::STRING
        FROM {{ source('SAPH', 'CONTROLTABLE') }}
        WHERE TABLE_NAME = 'SAP_FIM_EV_SKA1'
        )	
	QUALIFY ROW_NUMBER() OVER ( PARTITION BY KTOPL, SAKNR ORDER BY _FILEDATE DESC, _UPLOADDATE DESC) = 1
	),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		KTOPL as KTOPL,
		SAKNR as SAKNR,
		Case when "XBILK"='X' then 'true' else 'false' end as "XBILK",
		SAKAN as SAKAN,
		COALESCE("BILKT",'') as "BILKT",
		COALESCE(REGEXP_REPLACE(TRY_TO_DATE("ERDAT"),'-',''),'') as "ERDAT",
		ERNAM as ERNAM,
		COALESCE("GVTYP",'') as "GVTYP",
		KTOKS as KTOKS,
		MUSTR as MUSTR,
		VBUND as VBUND,
		Case when "XLOEV"='X' then 'true' else 'false' end as "XLOEV",
		Case when "XSPEA"='X' then 'true' else 'false' end as "XSPEA",
		Case when "XSPEB"='X' then 'true' else 'false' end as "XSPEB",
		Case when "XSPEP"='X' then 'true' else 'false' end as "XSPEP",
		COALESCE("MCOD1",'') as "MCOD1",
		FUNCAREA as FUNCAREA,
		COALESCE("GLACCOUNTTYPE",'') as "GLACCOUNTTYPE",
		LASTCHANGEDTS as LASTCHANGEDTS,
		UPDATE_DATE as UPDATE_DATE
    FROM source_data 
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        _AUDIT_LOG_ID,
        _ROW_HASH,
		KTOPL,
		SAKNR,
		XBILK,
		SAKAN,
		BILKT,
		ERDAT,
		ERNAM,
		GVTYP,
		KTOKS,
		MUSTR,
		VBUND,
		XLOEV,
		XSPEA,
		XSPEB,
		XSPEP,
		MCOD1,
		FUNCAREA,
		GLACCOUNTTYPE,
		LASTCHANGEDTS,
		UPDATE_DATE
    FROM transform_data 
)

	select * from type_data