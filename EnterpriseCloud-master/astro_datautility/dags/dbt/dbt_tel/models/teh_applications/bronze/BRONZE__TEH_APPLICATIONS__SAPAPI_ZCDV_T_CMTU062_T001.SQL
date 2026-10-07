/************
	Model file generated from SAPAPIUtility 
	*************/
/*
26/02 : GauravS:from this Model WERKS and NAME1 columns are only reffered in Common and these values are correctly coming from GMX source.
SAPAPI : only WERKS in(3100,3200,3300,3400)
SAPH : WERKS (1,3,1100,1200,1300,1400,1500,1600,1700,1800,1900,3100,3200,3300,3400)
 */
	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='ZCDV_T_CMTU062_T001',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT 
        _FILEDATE,
        _FILENAME,
        JSONFIELD:"BUKRS"::STRING AS BUKRS,
        JSONFIELD:"BUTXT"::STRING AS BUTXT,
        JSONFIELD:"DELFLAG"::STRING AS DELFLAG,
        JSONFIELD:"KTOPL"::STRING AS KTOPL,
        JSONFIELD:"LAND1"::STRING AS LAND1,
        JSONFIELD:"PERIV"::STRING AS PERIV,
        JSONFIELD:"PSL_INSDATE"::STRING AS PSL_INSDATE,
        JSONFIELD:"PSL_UPDDATE"::STRING AS PSL_UPDDATE,
        JSONFIELD:"SPRAS"::STRING AS SPRAS,
        JSONFIELD:"WAERS"::STRING AS WAERS
    FROM {{ source('SAPH','SAP_FIM_EV_T001') }}
		WHERE _FILEDATE::STRING = (
        SELECT MAX(RUN_TIME)::STRING
        FROM {{ source('SAPH', 'CONTROLTABLE') }}
        WHERE TABLE_NAME = 'SAP_FIM_EV_T001'

        )    
	QUALIFY ROW_NUMBER() OVER ( PARTITION BY BUKRS ORDER BY _FILEDATE DESC, _UPLOADDATE DESC) = 1
	),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        BUKRS,
        BUTXT,
        DELFLAG,
        KTOPL,
        LAND1,
        PERIV,
        PSL_INSDATE,
        PSL_UPDDATE,
        SPRAS,
        WAERS
    FROM source_data 
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        _AUDIT_LOG_ID,
        _ROW_HASH,
        BUKRS,
        BUTXT,
        DELFLAG,
        KTOPL,
        LAND1,
        PERIV,
        PSL_INSDATE,
        PSL_UPDDATE,
        SPRAS,
        WAERS
    FROM transform_data 
)

	select * from type_data