/************
	Model file generated from SAPAPIUtility 
	*************/

	-- disabled due to no SAP data
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='merge',
    	  alias='SAPAPI_ZCDV_T_CMTU082_A032',
    	  unique_key = ['KAPPL',
    'KSCHL',
    'VKORG',
    'VTWEG',
    'KONDA',
    'MATNR',
    'DATBI'],
    	  transient=false	
) }} 

	with source_data as (
	SELECT
		JSONFIELD:KAPPL::STRING AS KAPPL ,
 	 	JSONFIELD:KSCHL::STRING AS KSCHL , 
 	 	JSONFIELD:VKORG::STRING AS VKORG , 
 	 	JSONFIELD:VTWEG::STRING AS VTWEG , 
 	 	JSONFIELD:KONDA::STRING AS KONDA , 
 	 	JSONFIELD:MATNR::STRING AS MATNR , 
 	 	JSONFIELD:DATBI::STRING AS DATBI , 
 	 	JSONFIELD:DATAB::STRING AS DATAB , 
 	 	JSONFIELD:KNUMH::STRING AS KNUMH , 
 	 	JSONFIELD:update_date::STRING AS update_date ,
		_FILEDATE,
		_FILENAME
	from {{ source('SAPAPI', 'ZCDV_T_CMTU082_A032') }}
	WHERE 1=2
/* Adding false filter to the model so that we can enable it for DBT Project Consolidation, related to changes in k-card 34754 */
	--{% if is_tel_incremental() %}WHERE  _FILEDATE > IFNULL((SELECT MAX(_FILEDATE) FROM {{ this }}),'1970-01-01'){% endif %}
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:KAPPL::STRING,JSONFIELD:KSCHL::STRING,JSONFIELD:VKORG::STRING,JSONFIELD:VTWEG::STRING,JSONFIELD:KONDA::STRING,JSONFIELD:MATNR::STRING,JSONFIELD:DATBI::STRING  ORDER BY _FILENAME DESC, _FILEDATE DESC )) = 1

	),
	
	transform_data as (
	SELECT
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        KAPPL ,
        KSCHL ,
        VKORG ,
        VTWEG ,
        KONDA ,
        MATNR ,
        DATBI ,
        DATAB ,
        KNUMH ,
        update_date
from source_data
	),
	
	type_data as (
	SELECT
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        KAPPL ,
        KSCHL ,
        VKORG ,
        VTWEG ,
        KONDA ,
        MATNR ,
        DATBI ,
        DATAB ,
        KNUMH ,
        update_date
from transform_data
	)

	select * from type_data